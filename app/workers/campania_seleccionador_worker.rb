class CampaniaSeleccionadorWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default, retry: 2

  def perform
    campanias = CampaniaSeleccionador.seleccionar_comercios

    # CÓDIGO DE PRUEBA - ENVÍA SOLO A 2-3 REGISTROS, REDIRIGIENDO EL CORREO A hectorlazarte@yahoo.com.mx
    campanias.first(2).each_with_index do |registro, index|
      original_email = registro.email
      puts "Preparando comercio ##{index + 1} Intentos: #{registro.class.name} - Email original: #{original_email}"

      registro.email = "geosoft.internacional@gmail.com" # <- REDIRIGE SIN PERSISTIR
      puts "Enviando correo de prueba a #{registro.email}"

      EmailProtegido.deliver_now(CampaniaMailer, :promocion_comercio, registro)

      # Actualiza los campos de seguimiento
      registro.increment!(:intentos_envio)
      registro.update(ultima_fecha_envio: Time.current)
    end
    puts "CampaniaSeleccionadorWorker: envío de correos de prueba finalizado."

    # # PRODUCCIÓN:
    # campanias.each do |registro|
    #   EmailProtegido.deliver_later(CampaniaMailer, :promocion_comercio, registro)
    #   puts "Enviando correo a #{registro.email}"

    #   registro.increment!(:intentos_envio, 1, touch: true)
    #   registro.update(ultima_fecha_envio: Time.current)
    # end
    # puts "CampaniaSeleccionadorWorker: envío de correos finalizada."
  end
end
