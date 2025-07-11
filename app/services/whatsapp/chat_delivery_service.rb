# app/services/whatsapp/chat_delivery_service.rb
module Whatsapp
  class ChatDeliveryService
    def initialize(chat)
      @chat = chat
      @comercio = chat.comercio
      @usuario = chat.usuario_whatsapp
    end

    def enviar_al_comercio
      return unless @comercio&.telefono_whatsapp.present?

      Rails.logger.info("Enviando texto para Chat ##{@chat.id} al comercio #{@comercio.telefono_whatsapp}")

      Whatsapp::SendMessageService.new(
        to: @comercio.telefono_whatsapp,
        template_name: nil,
        template_language: nil,
        template_variables: []
      ).send_text_message(@chat.texto_para_envio)
    end

    def enviar_confirmacion_al_usuario
      return unless @usuario&.celular.present? && @comercio&.empresa.present?

      mensaje = <<~MSG.strip
        Su mensaje fue enviado a #{@comercio.empresa}. Ellos deberían contactarle directamente a su WhatsApp.
        Es un placer servirle. Gracias por usar Infomóvil.
      MSG

      Rails.logger.info("Enviando confirmación al usuario #{@usuario.celular} para Chat ##{@chat.id}")

      Whatsapp::SendMessageService.new(
        to: @usuario.celular,
        template_name: nil,
        template_language: nil,
        template_variables: []
      ).send_text_message(mensaje)
    end
  end
end
