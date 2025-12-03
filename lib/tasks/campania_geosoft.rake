# lib/tasks/campania_geosoft.rake

namespace :campania_geosoft do
  desc "Ejecuta campaña de correos para propietarios con JOIN a comercios. Uso: rake campania_geosoft:ejecutar[YYYY-MM-DD]"
  task :ejecutar, [:fecha] => :environment do |_t, args|
    fecha_str = args[:fecha]

    unless fecha_str.present?
      puts "ERROR: Debe proporcionar la fecha. Ejemplo:"
      puts "  bundle exec rake campania_geosoft:ejecutar[2025-01-15]"
      exit 1
    end

    begin
      puts (fecha_str)
      fecha = Date.strptime(fecha_str, "%Y-%m-%d")
    rescue ArgumentError
      puts "ERROR: Formato de fecha inválido: '#{fecha_str}'. Use YYYY-MM-DD."
      exit 1
    end

    puts "Iniciando campaña Geosoft para fecha de encuesta: #{fecha}"

    # JOIN entre CampaniaPropietariosEmail y Comercio
    scope = CampaniaPropietariosEmail
              .joins(:comercio)
              .where(comercios: { fecha_encuesta: fecha })

    total_registros = scope.count

    if total_registros.zero?
      puts "No se encontraron registros para la fecha #{fecha}."
      exit 0
    end

    puts "Se encontraron #{total_registros} registro(s) para la campaña."

    enviados = 0
    errores  = 0

    scope.find_each do |registro|
      begin
        puts "Enviando correo a #{registro.email} (Comercio ID #{registro.comercio_id})"
        GeosoftCampaignMailer.campania_propietario(registro).deliver_later
        enviados += 1
      rescue StandardError => e
        errores += 1

        email_destino = nil
        # intenta obtener el correo desde el comercio
        if registro.respond_to?(:comercio) && registro.comercio.respond_to?(:email)
          email_destino = registro.comercio.email
        end

        identificador =
          if email_destino.present?
            "destinatario #{email_destino}"
          else
            "registro ID #{registro.id}"
          end

        Rails.logger.error("[campania_geosoft] Error al enviar a #{identificador}: #{e.class} - #{e.message}")
        puts "Error al enviar a #{identificador}: #{e.class} - #{e.message}"
      end
    end

    puts "Campaña Geosoft finalizada:"
    puts "  Total registros: #{total_registros}"
    puts "  Correos enviados correctamente: #{enviados}"
    puts "  Errores de envío: #{errores}"
  end
end
