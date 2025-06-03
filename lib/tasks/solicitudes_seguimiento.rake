namespace :solicitudes do
  desc "Envío de seguimiento para solicitudes incompletas con recordatorio de formulario"
  task seguimiento: :environment do
    limite = 72.hours.ago

    Solicitud.where("updated_at < ?", limite)
             .where("estado < ?", 2)
             .where("intentos < ?", 3)
             .where(email_rebotado: 0)
             .find_each do |solicitud|

      begin
        comercio = solicitud.comercio
        pdf_data = FormularioInscripcionPdf.new(comercio).generar
        EmailProtegido.deliver_later(SolicitudSeguimientoMailer, :enviar_formulario, solicitud, pdf_data)

        solicitud.increment!(:intentos, 1, touch: true)
        puts "Enviado a #{solicitud.email} (Solicitud ##{solicitud.id})"
      rescue => e
        puts "Error en solicitud ##{solicitud.id}: #{e.message}"
      end

    end
  end
end
