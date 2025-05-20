class CampaniaSeleccionadorWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default, retry: 2

  def perform
    campanias = CampaniaSeleccionador.seleccionar_comercios

    # # CÓDIGO DE PRUEBA - ENVÍA SOLO A 2-3 REGISTROS, REDIRIGIENDO EL CORREO A geosoft.internacional@gmail.com
    # campanias.first(2).each_with_index do |campania, index|
    #   original_email = campania.email
    #   comercio = Comercio.find(campania.comercio_id)
    #   puts "Preparando comercio ##{index + 1} Intentos: #{campania.class.name} - Comercio: #{comercio.empresa}"

    #   campania.email = "test-m499zy4k9@srv1.mail-tester.com" if index == 0
    #   campania.email = "hclazarte@hotmail.com" if index == 1
    #   puts "Enviando correo de prueba a #{campania.email}"

    #   begin
    #     EmailProtegido.deliver_now(CampaniaMailer, :promocion_comercio, campania)
    #   rescue EmailProtegido::EmailBloqueadoError => e
    #     puts e.message         # “Envío bloqueado: …”
    #   end

    #   # Actualiza los campos de seguimiento
    #   campania.increment!(:intentos_envio)
    #   campania.update(ultima_fecha_envio: Time.current)
    # end
    # puts "CampaniaSeleccionadorWorker: envío de correos de prueba finalizado."

    # PRODUCCIÓN:
    campanias.each do |campania|
      begin
        EmailProtegido.deliver_later(CampaniaMailer, :promocion_comercio, campania)
        puts "Enviando correo a #{campania.email}"
      rescue EmailProtegido::EmailBloqueadoError => e
        puts e.message         # “Envío bloqueado: …”
      end
      campania.increment!(:intentos_envio, 1, touch: true)
      campania.update(ultima_fecha_envio: Time.current)
    end
    puts "CampaniaSeleccionadorWorker: envío de correos finalizada."
  end
end
