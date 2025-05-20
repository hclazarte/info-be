class SolicitudSeguimientoMailer < ApplicationMailer
  helper :unsub
  default from: 'solicitudes@infomovil.com.bo'

  def enviar_formulario(solicitud, pdf_data)
    @solicitud = solicitud
    @comercio = solicitud.comercio

    # enlace HTTPS firmado
    unsubscribe_link = ApplicationController.helpers.unsubscribe_url(@campania.email).unsubscribe_url(@campania.email)

    # cabecera List-Unsubscribe: incluye https y mailto
    headers['List-Unsubscribe'] =
      "<#{unsubscribe_link}>, <mailto:promociones@infomovil.com.bo?subject=unsubscribe>"

    attachments["formulario_inscripcion_#{@comercio.id}.pdf"] = pdf_data

    mail(
      to: @solicitud.email,
      subject: 'Formulario de inscripción para completar su registro en Infomóvil',
      content_transfer_encoding: 'base64',
      charset: 'UTF-8'
    ) do |format|
      format.html
    end
  end

  def unsubscribe_url(email)
    token = UnsubToken.generate(email)
    "#{Rails.configuration.base_url}/app/cancelar-suscripcion?token=#{token}"
  end
end