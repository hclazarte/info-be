class BuzonMailer < ApplicationMailer
  default from: 'portal@infomovil.com.bo' # Correo verificado en AWS SES

  def enviar_mensaje_portal(correo)
    @correo = correo
    destinatario = obtener_destinatario(correo.tipo)

    mail(
      from: 'portal@infomovil.com.bo',
      to: destinatario,
      subject: correo.asunto,
      body: correo.cuerpo
    ) do |format|
      format.text { render plain: "De: #{correo.nombre.presence || 'Anónimo'}\n\n#{correo.cuerpo}" }
      format.html do
        render html: "<p><strong>De:</strong> #{correo.nombre.presence || 'Anónimo'}</p><p>#{correo.cuerpo.gsub("\n",
                                                                                                                '<br>')}</p>".html_safe
      end
    end
    # Actualizar estado después del envío
    correo.update!(estado: 1)
  rescue StandardError => e
    correo.update!(estado: 2) # Fallido
    Rails.logger.error "Error enviando correo: #{e.message}"
  end

  private

  def obtener_destinatario(tipo)
    case tipo.to_sym
    when :sugerencia then 'sugerencias@infomovil.com.bo'
    when :consulta then 'consultas@infomovil.com.bo'
    when :reclamo then 'reclamos@infomovil.com.bo'
    else 'sugerencias@infomovil.com.bo'
    end
  end
end
