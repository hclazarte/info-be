# app/mailers/correo_mailer.rb
class CorreoMailer < ApplicationMailer
  helper :unsub # si lo usas en otros mailers
  default content_type: 'text/html; charset=UTF-8; format=flowed',
          content_transfer_encoding: 'base64'

  def enviar_personalizado(from:, to:, asunto:, mensaje:)
    @mensaje = mensaje # HTML permitido
    mail(from: from, to: to, subject: asunto) do |format|
      format.html { render layout: 'mailer' }
      format.text { render plain: strip_tags(@mensaje) + "\n\nInfomóvil\nInfomóvil - Todos los derechos reservados." }
    end
  end
end
