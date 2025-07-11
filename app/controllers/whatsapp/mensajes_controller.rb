module Whatsapp
  class MensajesController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      comercio_id = params[:comercio_id]
      celular = params[:celular]
      nombre = params[:nombre]
      cuerpo = params[:cuerpo]

      if comercio_id.blank? || celular.blank? || cuerpo.blank?
        return render json: { error: 'Parámetros requeridos: comercio_id, celular, mensaje' }, status: :unprocessable_entity
      end

      comercio = Comercio.find(comercio_id)
      empresa = comercio.empresa

      usuario_whatsapp = UsuarioWhatsapp.find_or_initialize_by(celular: celular)
      usuario_whatsapp.nombre = nombre
      usuario_whatsapp.save!

      chat = WhatsappChat.create!(
        comercio_id: comercio.id,
        usuario_whatsapp_id: usuario_whatsapp.id,
        mensaje: cuerpo,
        estado: :nuevo
      )

      Rails.logger.info("WhatsappChat ##{chat.id} creado para usuario #{usuario_whatsapp.celular} y comercio #{comercio.id}")

      unless usuario_whatsapp.whatsapp_autorizado?
        Rails.logger.info("Usuario no autorizado → solicitando autorización")

        Whatsapp::SendMessageService.new(
          to: celular,
          template_name: 'infomovil_usuario_informacion',
          template_language: 'es',
          template_variables: [
            {
              parameter_name: 'customer_name',
              text: empresa
            }
          ]
        ).send_template_message
      end

      unless comercio.whatsapp_autorizado?
        comercio_telefono = comercio.telefono_whatsapp
        if comercio_telefono.present?
          Rails.logger.info("Comercio no autorizado → solicitando autorización")

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
        else
          Rails.logger.warn("Comercio #{comercio.id} no tiene telefono_whatsapp definido → no se puede solicitar autorización")
        end
      end

      if comercio.whatsapp_autorizado?
        Rails.logger.info("Comercio autorizado → enviando texto libre al comercio")

        comercio_telefono = comercio.telefono_whatsapp
        if comercio_telefono.present?
          Whatsapp::ChatDeliveryService.new(chat).tap do |servicio|
            servicio.enviar_al_comercio
            chat.enviado!
            servicio.enviar_confirmacion_al_usuario
          end
        else
          Rails.logger.warn("Comercio #{comercio.id} no tiene telefono_whatsapp definido → no se puede enviar texto libre")
        end
      end

      render json: { id: chat.id }, status: :created

    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    end

  end
end
