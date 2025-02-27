class BuzonMailer < ApplicationMailer
  default from: 'portal@infomovil.com.bo' # Correo verificado en AWS SES

  def enviar_mensaje_portal(correo)
    @correo = correo
    destinatario = obtener_destinatario(correo.tipo)

    mail(
      from: 'portal@infomovil.com.bo',
      to: destinatario,
      subject: correo.asunto
    )
  end

  private

  def obtener_destinatario(tipo)
    case tipo.to_sym
    when :sugerencia then "sugerencias@infomovil.com.bo"
    when :consulta then "consultas@infomovil.com.bo"
    when :reclamo then "reclamos@infomovil.com.bo"
    else "sugerencias@infomovil.com.bo"
    end
  end  
end
