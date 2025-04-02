class SolicitudMailer < ApplicationMailer
  default from: 'solicitudes@infomovil.com.bo'

  def enviar_token(solicitud)
    @solicitud = solicitud

    asunto = if @solicitud.comercio.present?
      "Registro de #{@solicitud.comercio.empresa} en Infomóvil"
    else
      "Registro de su comercio en Infomóvil"
    end

    mail(
      to: @solicitud.email,
      subject: asunto
    ) do |format|
      format.html
    end
  end
end
