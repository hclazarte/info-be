namespace :solicitudes do
  desc "Envío de seguimiento para solicitudes incompletas con recordatorio de formulario"
  task seguimiento: :environment do
    limite = 72.hours.ago
    errores = []

    Solicitud.where("updated_at < ?", limite)
             .where("estado < ?", 2)
             .where("intentos < ?", 3)
             .where(email_rebotado: 0)
             .find_each do |solicitud|

      begin
        comercio = solicitud.comercio
        EmailProtegido.deliver_later(SolicitudSeguimientoMailer, :enviar_formulario, solicitud)

        solicitud.increment!(:intentos, 1, touch: true)
        puts "Enviado a #{solicitud.email} (Solicitud ##{solicitud.id})"
      rescue => e
        error_msg = "Error en solicitud ##{solicitud.id}: #{e.class} - #{e.message}"
        errores << error_msg
        puts error_msg
      end
    end

    if errores.any?
      puts "\n--- Resumen de errores ---"
      errores.each { |err| puts err }
      exit(1)
    end
  end
end
