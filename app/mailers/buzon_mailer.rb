class BuzonMailer < ApplicationMailer
  default from: 'portal@infomovil.com.bo' # Correo verificado en AWS SES

  def enviar_mensaje_portal(correo)
    @correo = correo
    @base_url = Rails.configuration.base_url
    destinatario = obtener_destinatario(correo.tipo)

    mail(
      from: 'portal@infomovil.com.bo',
      to: destinatario,
      subject: correo.asunto
    ) do |format|
      format.text do
        render plain: <<~TEXT
          De: #{@correo.nombre.presence || 'Anónimo'}
          Correo Electrónico: #{@correo.remitente}
          Categoría: #{@correo.tipo}
          Asunto: #{@correo.asunto}

          #{@correo.cuerpo}
        TEXT
      end

      format.html # renderiza automáticamente app/views/buzon_mailer/enviar_mensaje_portal.html.erb
    end

    correo.update!(estado: 1)
  rescue StandardError => e
    correo.update!(estado: 2)
    Rails.logger.error "Error enviando correo: #{e.message}"
  end

  private

  def obtener_destinatario(tipo)
    case tipo.to_s.downcase.to_sym
    when :sugerencia then 'sugerencias@infomovil.com.bo'
    when :consulta then 'consultas@infomovil.com.bo'
    when :reclamo then 'reclamos@infomovil.com.bo'
    else 'sugerencias@infomovil.com.bo'
    end
  end
end
