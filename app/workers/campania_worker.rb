class CampaniaWorker
  CONFIG_PATH = Rails.root.join('config', 'campania_email.yml')
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 2

  def perform (fecha = nil)
    config = load_config

    if fecha.nil?
      campanias = CampaniaSeleccionador.seleccionar_comercios(config[:aleatorios])
      campanias += CampaniaSeleccionador.seleccionar_comercios_nuevos(config[:nuevos])
      puts "[CampaniaWorker] Ejecutando nueva campaña."
    else
      fecha_parseada = Date.parse(fecha) rescue nil
      unless fecha_parseada
        puts "[CampaniaWorker] Fecha inválida: #{fecha}"
        return
      end
      campanias = CampaniaPropietariosEmail
                    .where("TRUNC(created_at) = TO_DATE(?, 'YYYY-MM-DD')", fecha_parseada.to_s)
      puts "[CampaniaWorker] Reintentando envío para campaña con fecha: #{fecha_parseada} (#{campanias.count} registros)"
    end

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
    # puts "CampaniaWorker: envío de correos de prueba finalizado."

    # PRODUCCIÓN:
    AdministracionMailer.notificacion("Campaña Propietarios email iniciada").deliver_later
    campanias.each_with_index do |campania, i|
      begin
        EmailProtegido.deliver_later(CampaniaMailer, :promocion_comercio, campania)
        puts "[#{i + 1}] Enviando correo a #{campania.email}"
      rescue EmailProtegido::EmailBloqueadoError => e
        puts e.message         # “Envío bloqueado: …”
      end
      campania.increment!(:intentos_envio, 1, touch: true)
      campania.update(ultima_fecha_envio: Time.current)
    end
    puts "************************** CampaniaWorker: envío #{campanias.size} correos."
  end

  private

  def load_config
    valores_por_defecto = { nuevos: 50, aleatorios: 50 }

    if File.exist?(CONFIG_PATH)
      archivo = YAML.load_file(CONFIG_PATH).transform_keys(&:to_sym)
      valores = valores_por_defecto.merge(archivo)

      # Validación simple
      {
        nuevos: valores[:nuevos].to_i > 0 ? valores[:nuevos].to_i : 50,
        aleatorios: valores[:aleatorios].to_i > 0 ? valores[:aleatorios].to_i : 50
      }
    else
      valores_por_defecto
    end
  end
end
