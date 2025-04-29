class CampaniaSeleccionadorWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default, retry: 2

  def perform
    seleccionados = CampaniaSeleccionador.seleccionar_comercios

    # puts "CampaniaSeleccionadorWorker: seleccionados #{seleccionados.size} comercios."
    # # CÓDIGO DE PRUEBA - ENVÍA SOLO A 2-3 REGISTROS, REDIRIGIENDO EL CORREO A hectorlazarte@yahoo.com.mx
    # seleccionados.first(3).each_with_index do |comercio, index|
    #   original_email = comercio.email
    #   puts "Preparando comercio ##{index + 1} ID: #{comercio.id} - Email original: #{original_email}"

    #   comercio.email = "hectorlazarte@yahoo.com.mx" # <- REDIRIGE SIN PERSISTIR
    #   puts "Enviando correo de prueba a #{comercio.email}"

    #   CampaniaMailer.promocion_comercio(comercio).deliver_now
    # end
    # puts "CampaniaSeleccionadorWorker: envío de correos de prueba finalizado."

    # PRODUCCIÓN:
    seleccionados.each do |comercio|
      CampaniaMailer.promocion_comercio(comercio).deliver_later
      puts "Enviando correo de prueba a #{comercio.email}"
    end
    puts "CampaniaSeleccionadorWorker: envío de correos de prueba finalizada."
  end
end
