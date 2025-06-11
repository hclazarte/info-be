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
        from = message['from'] # Ej.: '59171234567'
        text = message.dig('text', 'body') || '(sin texto)'

        Rails.logger.info("Mensaje recibido de #{from}: '#{text}'")

        comercio = Comercio.find_by(telefono_whatsapp: from)
        usuario_whatsapp = UsuarioWhatsapp.find_by(celular: from)

        # Guarda el mensaje en un nuevo WhatsappChat con estado recibido
        chat = WhatsappChat.create!(
          comercio_id: comercio&.id,
          usuario_whatsapp_id: usuario_whatsapp&.id,
          mensaje: text,
          estado: :recibido
        )
        Rails.logger.info("WhatsappChat ##{chat.id} creado en estado recibido")

        if comercio
          Rails.logger.info("Mensaje recibido del COMERCIO ID=#{comercio.id}")
          comercio.update!(whatsapp_fecha_autorizado: Time.current)

          # Buscar todos los chats nuevos del comercio
          chats_pendientes = WhatsappChat.where(comercio_id: comercio.id, estado: :nuevo)

          chats_pendientes.each do |pending_chat|
            if comercio.whatsapp_autorizado? && pending_chat.usuario_whatsapp&.whatsapp_autorizado?
              enviar_texto_al_comercio(pending_chat)
              pending_chat.enviado!
              Rails.logger.info("Chat ##{pending_chat.id} enviado y actualizado a estado ENVIADO")
            else
              Rails.logger.info("Chat ##{pending_chat.id} no autorizado → se mantiene en estado NUEVO")
            end
          end
        elsif usuario_whatsapp
          Rails.logger.info("Mensaje recibido del USUARIO #{usuario_whatsapp.celular}")
          usuario_whatsapp.update!(whatsapp_fecha_autorizado: Time.current)

          # Buscar todos los chats nuevos del usuario
          chats_pendientes = WhatsappChat.where(usuario_whatsapp_id: usuario_whatsapp.id, estado: :nuevo)

          chats_pendientes.each do |pending_chat|
            if pending_chat.comercio&.whatsapp_autorizado? && usuario_whatsapp.whatsapp_autorizado?
              enviar_texto_al_comercio(pending_chat)
              pending_chat.enviado!
              Rails.logger.info("Chat ##{pending_chat.id} enviado y actualizado a estado ENVIADO")
            else
              Rails.logger.info("Chat ##{pending_chat.id} no autorizado → se mantiene en estado NUEVO")
            end
          end
        else
          Rails.logger.warn("Mensaje recibido de número DESCONOCIDO #{from} → no se actualiza ninguna autorización")
        end
      end

      head :ok
    end

    private

    def enviar_texto_al_comercio(chat)
      comercio = chat.comercio
      comercio_telefono = comercio&.telefono_whatsapp
      return unless comercio && comercio_telefono.present?

      Rails.logger.info("Enviando texto para Chat ##{chat.id} al comercio #{comercio_telefono}")

      Whatsapp::SendMessageService.new(
        to: comercio_telefono,
        template_name: nil,
        template_language: nil,
        template_variables: []
      ).send_text_message(chat.texto_para_envio)
    end
  end
end
