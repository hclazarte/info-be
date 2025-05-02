class SolicitudSeguimientoMailer < ApplicationMailer
  default from: 'solicitudes@infomovil.com.bo'

  def enviar_formulario(solicitud, pdf_data)
    @solicitud = solicitud
    @comercio = solicitud.comercio

    attachments["formulario_inscripcion_#{@comercio.id}.pdf"] = pdf_data

    mail(
      to: @solicitud.email,
      subject: 'Formulario de inscripción para completar su registro en Infomóvil'
    ) do |format|
      format.html
    end
  end
end