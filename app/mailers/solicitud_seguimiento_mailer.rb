# app/mailers/solicitud_seguimiento_mailer.rb
class SolicitudSeguimientoMailer < ApplicationMailer
  helper :unsub
  default from: 'solicitudes@infomovil.com.bo'

  def enviar_formulario(solicitud, pdf_data)
    @solicitud = solicitud
    @comercio  = solicitud.comercio

    unsubscribe_link = ApplicationController.helpers.unsubscribe_url(@solicitud.email)

    headers['List-Unsubscribe'] =
      "<#{unsubscribe_link}>, <mailto:solicitudes@infomovil.com.bo?subject=unsubscribe>"

    attachments["formulario_inscripcion_#{@comercio.id}.pdf"] = pdf_data

    mail(
      to: @solicitud.email,
      subject: 'Formulario de inscripción para completar su registro en Infomóvil'
    ) do |format|
      format.html do
        render html: render_to_string(
          template: 'solicitud_seguimiento_mailer/enviar_formulario',
          layout: 'mailer'
        ).html_safe, 
        content_type: 'text/html; charset=UTF-8; format=flowed',
        content_transfer_encoding: 'base64'
      end
    end
  end
end
