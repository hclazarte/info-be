class CampaniaMailer < ApplicationMailer
  helper :unsub
  default from: 'promociones@infomovil.com.bo'

  def promocion_comercio(campania)
    @campania      = campania
    @comercio      = Comercio.find(campania.comercio_id)
    @base_url      = Rails.configuration.base_url
    @ciudad_nombre = @comercio.ciudad&.ciudad
    @ciudad_slug   = @ciudad_nombre.to_s.parameterize
    @comercio_slug = @comercio.empresa.to_s.parameterize

    unsubscribe_link = ApplicationController.helpers.unsubscribe_url(@campania.email)

    headers['List-Unsubscribe'] =
      "<#{unsubscribe_link}>, <mailto:promociones@infomovil.com.bo?subject=unsubscribe>"

    mail(
      to: @campania.email,
      subject: 'Formulario de inscripción para completar su registro en Infomóvil',
    ) do |format|
      format.html do
        render html: render_to_string(
          template: 'campania_mailer/promocion_comercio',
          layout: 'mailer'
        ).html_safe, 
        content_type: 'text/html; charset=UTF-8; format=flowed',
        content_transfer_encoding: 'base64'
      end
    end
  end
end
