module Webhooks
  class WhatsappController < ApplicationController
    skip_before_action :verify_authenticity_token

    VERIFY_TOKEN = 'infomovil2025'

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

        # Busca la conversación activa con ese celular
        chat = WhatsappChat.find_by(celular: from)

        if chat
          chat.whatsapp_mensajes.create!(
            cuerpo: text,
            remitente: :comercio
          )
          Rails.logger.info("Mensaje registrado en chat ##{chat.id} desde #{from}")
        else
          Rails.logger.warn("No se encontró conversación activa para el número #{from}")
        end
      end

      head :ok
    end
  end
end
