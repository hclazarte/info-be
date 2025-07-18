class ConfirmacionMailer < ApplicationMailer
  helper :unsub
  default from: 'portal@infomovil.com.bo'

  def confirmacion_usuario(correo)
    @email = correo.remitente
    
    Rails.logger.info "Enviando confirmación automática a: #{@email}"

    mail(
      to: @email,
      subject: 'Hemos recibido su mensaje - Infomóvil'
    ) do |format|
      format.html do
        render html: render_to_string(
          template: 'confirmacion_mailer/confirmacion_usuario',
          layout: 'mailer'
        ).html_safe,
        content_type: 'text/html; charset=UTF-8; format=flowed',
        content_transfer_encoding: 'base64'
      end
    end
  end
end
