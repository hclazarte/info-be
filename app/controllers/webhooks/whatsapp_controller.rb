module Webhooks
  class WhatsappController < ApplicationController
    skip_before_action :verify_authenticity_token

    # Verificación inicial del webhook con Meta
    def verify
      if params['hub.mode'] == 'subscribe' && params['hub.verify_token'] == ENV['INFOMOVIL_WHATSAPP_VERIFY_TOKEN']
        render plain: params['hub.challenge'], status: :ok
      else
        render plain: 'Verification failed', status: :forbidden
      end
    end

    # Recepción de mensajes entrantes desde WhatsApp Cloud API
    def receive
      Rails.logger.info("WhatsApp webhook recibido: #{params.to_unsafe_h}")

      entry = params['entry']&.first
      changes = entry&.dig('changes')&.first
      value = changes&.dig('value')
      messages = value&.dig('messages')

      if messages.present?
        message = messages.first
        from = message['from']                             # número en formato internacional (ej. '59171234567')
        text = message.dig('text', 'body') || '(sin texto)'

        # Primero buscamos si el número corresponde a un chat (usuario)
        chat = WhatsappChat.find_by(celular: from)

        if chat
          chat.whatsapp_mensajes.create!(
            cuerpo: text,
            remitente: :usuario,
            destinatario: :plataforma # ← Es un mensaje que va hacia Infomóvil (backend)
          )
          Rails.logger.info("Mensaje del usuario registrado en chat ##{chat.id} desde #{from}")

          # Validación del canal de usuario
          unless chat.whatsapp_verificado
            chat.update(whatsapp_verificado: true)
            Rails.logger.info("Canal de usuario verificado para chat ##{chat.id} (#{from})")

            # Paso 4: contactar comercio
            contactar_comercio(chat)
          end

        else
          # Si no es un usuario, verificamos si es un comercio
          comercio = Comercio.find_by(telefono_whatsapp: from)

          if comercio
            Rails.logger.info("Mensaje recibido del comercio ID=#{comercio.id} (#{from}): '#{text}'")

            # Normalizamos la respuesta
            texto_normalizado = TextFormatter.normalizar_mensaje_recibido(text)

            respuestas_negativas = ['equivocado', 'no soy yo', 'error', 'incorrecto']

            # Buscamos si hay un chat abierto para este comercio y celular
            chat = WhatsappChat.find_by(comercio_id: comercio.id, celular: from)

            if chat
              chat.whatsapp_mensajes.create!(
                cuerpo: text,
                remitente: :comercio,
                destinatario: :plataforma
              )
              Rails.logger.info("Mensaje del comercio registrado en chat ##{chat.id} desde #{from}")
            end

            # Validación del canal del comercio
            if respuestas_negativas.include?(texto_normalizado)
              comercio.update(whatsapp_verificado: false)
              Rails.logger.info("Canal de comercio ID=#{comercio.id} marcado como NO VERIFICADO (#{from})")
            else
              Rails.logger.info("Comercio ID=#{comercio.id} ha aceptado la conversación")

              if chat
                enviar_consulta_al_comercio(chat)
                notificar_usuario_confirmacion(chat)
              else
                Rails.logger.warn("No se encontró chat para comercio ID=#{comercio.id} y número #{from}")
              end
            end

          else
            # Si no es ni usuario ni comercio
            Rails.logger.warn("Mensaje recibido de número desconocido #{from}")
          end
        end
      end

      head :ok
    end


    private

    def contactar_comercio(chat)
      return unless chat.whatsapp_verificado
      return unless chat.comercio_id.present?

      comercio = Comercio.find_by(id: chat.comercio_id)
      unless comercio
        Rails.logger.warn("No se encontró el comercio ID=#{chat.comercio_id} para chat ##{chat.id}")
        return
      end

      comercio_telefono = comercio.telefono_whatsapp
      unless comercio_telefono.present?
        Rails.logger.warn("Comercio ID=#{comercio.id} no tiene telefono_whatsapp definido")
        return
      end

      empresa = comercio.empresa.presence || 'Comercio'

      # Enviar plantilla al comercio
      Rails.logger.info("Enviando plantilla 'infomovil_contacto_comercios' al comercio ID=#{comercio.id} (#{comercio_telefono})")

      Whatsapp::SendMessageService.new(
        to: comercio_telefono,
        template_name: 'infomovil_contacto_comercios',
        template_language: 'es',
        template_variables: [
          {
            parameter_name: 'customer_name',
            text: empresa
          }
        ]
      ).send_template_message
      WhatsappMensaje.create!(
        whatsapp_chat_id: chat.id,
        cuerpo: 'infomovil_contacto_comercios',
        remitente: :plataforma,
        destinatario: :comercio
      )
    end

    def enviar_consulta_al_comercio(chat)
      return unless chat.whatsapp_verificado
      return unless chat.comercio_id.present?

      comercio = Comercio.find_by(id: chat.comercio_id)
      unless comercio
        Rails.logger.warn("No se encontró el comercio ID=#{chat.comercio_id} para chat ##{chat.id}")
        return
      end

      comercio_telefono = comercio.telefono_whatsapp
      unless comercio_telefono.present?
        Rails.logger.warn("Comercio ID=#{comercio.id} no tiene telefono_whatsapp definido")
        return
      end

      empresa = comercio.empresa.presence || 'Comercio'

      # Buscar el último mensaje del usuario en este chat
      mensaje_usuario = chat.whatsapp_mensajes.where(remitente: :usuario).order(created_at: :desc).first

      unless mensaje_usuario
        Rails.logger.warn("No se encontró mensaje del usuario en chat ##{chat.id}")
        return
      end

      # Frases de cierre amables
      frases_cierre = [
        'Le deseamos un excelente negocio.',
        '¡Mucho éxito con su nuevo cliente!',
        '¡Gracias por formar parte de Infomóvil!',
        '¡Le deseamos un día lleno de ventas!',
        '¡Que tenga una excelente jornada comercial!'
      ]

      frase_final = frases_cierre.sample

      # Construir el cuerpo del mensaje completo
      cuerpo_mensaje = <<~MSG
        Nombre del usuario: #{chat.nombre}
        Número del usuario: #{chat.celular}
        Consulta: #{mensaje_usuario.cuerpo}

        #{frase_final}
      MSG

      # Enviar el mensaje como plantilla libre
      Rails.logger.info("Enviando mensaje original del usuario al comercio ID=#{comercio.id} (#{comercio_telefono})")

      Whatsapp::SendMessageService.new(
        to: comercio_telefono,
        template_name: nil,
        template_language: nil,
        template_variables: []
      ).send_text_message(cuerpo_mensaje)
      WhatsappMensaje.create!(
        whatsapp_chat_id: chat.id,
        cuerpo: cuerpo_mensaje,
        remitente: :plataforma,
        destinatario: :comercio
      )
    end

    def notificar_usuario_confirmacion(chat)
      return unless chat
      return unless chat.comercio_id.present?

      comercio = Comercio.find_by(id: chat.comercio_id)
      unless comercio
        Rails.logger.warn("No se encontró el comercio ID=#{chat.comercio_id} para chat ##{chat.id}")
        return
      end

      usuario_telefono = chat.celular
      empresa = comercio.empresa.presence || 'el comercio'

      frases_cierre_usuario = [
        '¡Gracias por usar Infomóvil, le deseamos que su consulta sea un éxito!',
        "¡Esperamos que tenga una excelente experiencia con #{empresa}!",
        '¡Gracias por confiar en Infomóvil, estamos para servirle!',
        '¡Su consulta ha sido enviada, le deseamos un excelente día!',
        '¡Estamos a su disposición para cualquier otra consulta en Infomóvil!'
      ]

      frase_usuario = frases_cierre_usuario.sample

      cuerpo_usuario = <<~MSG
        Hemos contactado a #{empresa} en su nombre, y le hemos enviado sus datos de contacto.

        #{frase_usuario}
      MSG

      Rails.logger.info("Enviando confirmación al usuario #{usuario_telefono} para chat ##{chat.id}")

      Whatsapp::SendMessageService.new(
        to: usuario_telefono,
        template_name: nil,
        template_language: nil,
        template_variables: []
      ).send_text_message(cuerpo_usuario)
      WhatsappMensaje.create!(
        whatsapp_chat_id: chat.id,
        cuerpo: cuerpo_usuario,
        remitente: :plataforma,
        destinatario: :usuario
      )
    end
  end
end
