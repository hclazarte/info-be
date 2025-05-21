class CorreoUsuarioMailer < ApplicationMailer
  helper :unsub
  default from: 'portal@infomovil.com.bo'

  def enviar_mensaje_usuario(correo_usuario)
    @correo_usuario = correo_usuario
    @comercio       = Comercio.find(correo_usuario.comercio_id)
    @base_url       = Rails.configuration.base_url

    unsubscribe_link = ApplicationController.helpers.unsubscribe_url(@correo_usuario.destinatario)

    headers['List-Unsubscribe'] =
      "<#{unsubscribe_link}>, <mailto:promociones@infomovil.com.bo?subject=unsubscribe>"

    mail(
      to: @correo_usuario.destinatario,
      subject: @correo_usuario.asunto,
    ) do |format|
      format.html do
        render html: render_to_string(
          template: 'correo_usuario_mailer/enviar_mensaje_usuario',
          layout: 'mailer'
        ).html_safe, 
        content_type: 'text/html; charset=UTF-8; format=flowed',
        content_transfer_encoding: 'base64'
      end
    end
  end
end