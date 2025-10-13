# app/mailers/promotor_mailer.rb
class PromotorMailer < ApplicationMailer
  helper :unsub
  default from: 'promotores@infomovil.com.bo'

  def informativo(promotor)
    @promotor = promotor
    @nombre = promotor.nombre
    @link_reunion = ENV.fetch('PROMOTORES_REUNION_URL', 'https://calendar.app.google/oCoiffvc2XEsU4wW9')

    Rails.logger.info "Enviando correo informativo a candidato a promotor: #{@promotor.email}"

    mail(
      to: @promotor.email,
      subject: 'Bienvenido al Programa de Promotores de Infomóvil'
    ) do |format|
      format.html do
        render html: render_to_string(
          template: 'promotor_mailer/informativo',
          layout: 'mailer'
        ).html_safe,
        content_type: 'text/html; charset=UTF-8; format=flowed',
        content_transfer_encoding: 'base64'
      end
    end
  end
end
