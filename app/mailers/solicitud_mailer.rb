class SolicitudMailer < ApplicationMailer
  default from: 'solicitudes@infomovil.com.bo'

  def enviar_token(solicitud)
    @solicitud = solicitud
    @base_url = Rails.configuration.base_url

    asunto = if @solicitud.comercio.present?
               "Registro de #{@solicitud.comercio.empresa} en Infomóvil"
             else
               'Registro de su comercio en Infomóvil'
             end

    mail(
      to: @solicitud.email,
      bcc: 'administracion@infomovil.com.bo',
      subject: asunto, &:html
    )
  end
end
