# app/mailers/correo_mailer.rb
class CorreoMailer < ApplicationMailer
  include ActionView::Helpers::SanitizeHelper

  def enviar_personalizado(from:, to:, asunto:, mensaje:)
    @mensaje = mensaje.to_s

    mail(from: from, to: to, subject: asunto) do |format|
      format.html { render layout: 'mailer' }
      format.text do
        texto = strip_tags(@mensaje)
        render plain: texto  # sin footer; lo pone el layout .text.erb
      end
    end
  end
end
