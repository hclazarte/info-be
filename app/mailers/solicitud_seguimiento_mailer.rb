# app/mailers/solicitud_seguimiento_mailer.rb
class SolicitudSeguimientoMailer < ApplicationMailer
  helper :unsub
  default from: 'solicitudes@infomovil.com.bo'

  def enviar_formulario(solicitud, pdf_data)
    @solicitud = solicitud
    @comercio  = solicitud.comercio

    # Enlace de baja firmado (usamos el helper declarado en unsub_helper.rb)
    unsubscribe_link = ApplicationController.helpers.unsubscribe_url(@solicitud.email)

    # Cabecera List-Unsubscribe
    headers['List-Unsubscribe'] =
      "<#{unsubscribe_link}>, <mailto:solicitudes@infomovil.com.bo?subject=unsubscribe>"

    # Adjuntar PDF
    attachments["formulario_inscripcion_#{@comercio.id}.pdf"] = pdf_data

    # Enviar mail (parte HTML en base64, UTF-8)
    mail(to:      @solicitud.email,
         subject: 'Formulario de inscripción para completar su registro en Infomóvil') do |format|

      format.html content_type:              'text/html; charset=UTF-8',
                  content_transfer_encoding: 'base64'
    end
  end
end
