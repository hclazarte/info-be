class CampaniaSeleccionador
  def self.seleccionar_comercios
    hoy = Time.zone.today

    # Paso 1: Buscar comercios válidos (sin cargar todos en memoria)
    comercio_scope = Comercio
      .left_joins(:solicitudes)
      .where.not(email: nil)
      .where(bloqueado: 0)
      .where(campania_iniciada: 0)
      .where(activo: 1)
      .where("solicitudes.fecha_fin_servicio IS NULL OR solicitudes.fecha_fin_servicio <= ?", hoy)
      .where.not(fecha_encuesta: nil)
      .distinct

    return if comercio_scope.empty?

    # Paso 2: Calcular diferencias de días y ponderaciones logarítmicas
    fecha_max = comercio_scope.maximum(:fecha_encuesta)
    fecha_min = comercio_scope.minimum(:fecha_encuesta)

    max_dif = [(hoy - fecha_min.to_date).to_i, 1].max
    min_dif = [(hoy - fecha_max.to_date).to_i, 1].max

    ponderacion_max = 1.0 / Math.log(max_dif + 1)
    ponderacion_min = 1.0 / Math.log(min_dif + 1)

    puts "Ponderación mayor (más antiguo): #{ponderacion_max.round(6)}"
    puts "Ponderación menor (más reciente): #{ponderacion_min.round(6)}"

    seleccionados = []
    total_registros = comercio_scope.count

    50.times do |i|
      suma_peso = 0
      intentos = 0
      seleccionado = nil

      while suma_peso < ponderacion_max && intentos < 20
        offset_random = rand(total_registros)
        comercio = comercio_scope.select(:id, :email, :fecha_encuesta).offset(offset_random).limit(1).first

        break unless comercio

        dias = [(hoy - comercio.fecha_encuesta.to_date).to_i, 1].max
        peso = 1.0 / Math.log(dias + 1)

        suma_peso += peso
        seleccionado = comercio
        intentos += 1
      end

      if seleccionado
        puts "[#{i + 1}] Seleccionado Comercio ID: #{seleccionado.id}, Email: #{seleccionado.email}, Fecha Encuesta: #{seleccionado.fecha_encuesta}"
        seleccionados << seleccionado
        total_registros -= 1
        comercio_scope = comercio_scope.where.not(id: seleccionado.id)
      else
        puts "[#{i + 1}] No se pudo seleccionar un comercio en los intentos permitidos."
      end
    end

    # Paso 3: Marcar comercios y crear entradas de campaña
    if seleccionados.any?
      Comercio.where(id: seleccionados.map(&:id)).update_all(campania_iniciada: 1)

      seleccionados.each do |comercio|
        CampaniaPropietariosEmail.create!(
          id_comercio: comercio.id,
          email: comercio.email,
          enviado: false,
          clic: false,
          intentos_envio: 0
        )
      end
    else
      puts "No se seleccionaron comercios en esta ejecución."
    end
  end
end
