require 'rest-client'
require 'json'
require 'yaml'

class CrawlInfo
  CONFIG_PATH = Rails.root.join('config', 'crawl_info.yml')
  LOG_PATH = Rails.root.join('log', 'crawl_info.log')

  def self.run
    new.run
  end

  def initialize
    @config = load_config
    @log = File.open(LOG_PATH, 'a')
    @last_id = @config['last']
    @step = @config['records']
    @ultima_fecha = nil
    @ultimo_id_exitoso = nil
  end

  def run
    log('INICIO DE SINCRONIZACIÓN')
    @stat_5 = 0

    (@last_id + 1).upto(@last_id + @step) do |id|
      process_id(id)
    rescue StandardError => e
      log("Error procesando #{e.message}", id)
      @stat_5 += 1
    end
    @last_id += @step

    save_config if @stat_5.zero?
    log('FIN DE SINCRONIZACIÓN')
    @log.close
    @stat_5.zero?
  end

  private

  # Procesar ID específico
  def process_id(id_seprec)
    activo = true
    empresa_data = fetch_data("https://servicios.seprec.gob.bo/api/empresas/#{id_seprec}", id_seprec)
    return log('Empresa no encontrada', id_seprec) unless empresa_data

    if empresa_data.dig(
      'datos', 'estado'
    ).to_s != 'ACTIVO'
      return log("Error procesando comercio en estado #{empresa_data.dig('datos', 'estado')}",
                 id_seprec)
    end

    establecimientos_data = fetch_data("https://servicios.seprec.gob.bo/api/empresas/#{id_seprec}/establecimientos",
                                       id_seprec)
    return log('Establecimientos no encontrados', id_seprec) if establecimientos_data.empty?

    id_est = establecimientos_data.dig('datos', 'filas', 0, 'id')

    informacion_data = fetch_data(
      "https://servicios.seprec.gob.bo/api/empresas/informacionBasicaEmpresa/#{id_seprec}/establecimiento/#{id_est}", id_seprec, true
    )
    unless informacion_data && informacion_data['mensaje'] != 'No se encontró la empresa o esta inactiva.'
      activo = false
    end
    process_comercio(id_seprec, id_est, empresa_data, establecimientos_data, informacion_data, activo)

    # Actualizar la última fecha procesada
    fecha_inscripcion = begin
      DateTime.parse(empresa_data.dig('datos', 'fechaInscripcion'))
    rescue StandardError
      nil
    end
    @ultima_fecha = fecha_inscripcion if fecha_inscripcion && (!@ultima_fecha || fecha_inscripcion > @ultima_fecha)
    @ultimo_id_exitoso = id_seprec if fecha_inscripcion
  end

  def process_comercio(id_seprec, id_est, empresa_data, _establecimientos_data, informacion_data, activo)
    # Paso 1: Buscar el comercio existente o inicializar uno nuevo
    comercio = Comercio.where(seprec: id_seprec, seprec_est: id_est).first
    comercio ||= Comercio.new(seprec: id_seprec, seprec_est: id_est)

    # Paso 2: Asignar atributos
    comercio.latitud = empresa_data.dig('datos', 'direccion', 'latitud')
    comercio.longitud = empresa_data.dig('datos', 'direccion', 'longitud')
    comercio.fecha_registro ||= DateTime.now
    comercio.fecha_encuesta = DateTime.parse(empresa_data.dig('datos', 'fechaInscripcion'))
    comercio.zona_nombre = format_zona(empresa_data)
    comercio.fundempresa = empresa_data.dig('datos', 'matriculaAnterior')
    # comercio.numero_comercio
    comercio.calle_numero = "#{empresa_data.dig('datos', 'direccion', 'nombreVia')} Nº #{format_numero(empresa_data)}"
    # comercio.planta = empresa_data.dig("datos", "direccion", "piso")
    # comercio.numero_local = empresa_data.dig("datos", "direccion", "numeroNombreAmbiente")
    contacto_telefono = informacion_data&.dig('datos', 'contactos')&.find do |c|
      c['tipoContacto'] == 'TELEFONO'
    end || nil
    comercio.telefono1 = contacto_telefono.dig('descripcion', 0, 'numero') if contacto_telefono
    # comercio.horario
    comercio.observacion = "SEPREC:#{activo ? ' ACTIVANDO' : ' DESACTIVANDO'}"
    comercio.empresa = format_razon_social(empresa_data.dig('datos', 'razonSocial'))
    # comercio.observacion2
    contacto_correo = informacion_data&.dig('datos', 'contactos')&.find { |c| c['tipoContacto'] == 'CORREO' } || nil
    comercio.email = contacto_correo.dig('descripcion', 0, 'correo') if contacto_correo
    # comercio.pagina_web
    comercio.servicios = format_servicios(informacion_data)
    # activo
    comercio.activo = activo
    # comercio.ofertas
    comercio.nit = empresa_data.dig('datos', 'nit')

    # Paso 3: Asociar la ciudad, crearla si no existe
    cod_municipio = empresa_data.dig('datos', 'direccion', 'codMunicipio')
    ciudad = Ciudad.find_or_create_by(
      cod_municipio: cod_municipio,
      cod_pais: 'BO' # País fijo como "Bolivia"
    ) do |new_ciudad|
      # Solo se ejecuta si se crea una nueva ciudad
      new_ciudad.ciudad = capitalize_words(empresa_data.dig('datos', 'direccion', 'municipio', 'descripcion'))
      new_ciudad.pais = 'Bolivia'
    end

    comercio.ciudad = ciudad

    # Paso 4: Guardar el comercio
    if comercio.save
      log("Comercio procesado: #{comercio.empresa}", id_seprec)
    else
      log("Error guardando comercio: #{comercio.errors.full_messages.join(', ')}", id_seprec)
    end
  rescue StandardError => e
    log("Error procesando comercio: #{e.message}", id_seprec)
  end

  # Métodos Auxiliares

  def format_zona(empresa_data)
    zona = empresa_data.dig('datos', 'direccion', 'nombreSubdivisionGeografica')

    # Return nil immediately if zona is nil
    return nil if zona.nil?

    return zona if zona == 'BARRIO LINDO'

    # Apply transformations safely
    zona = zona.gsub('.', '').gsub('-', '').strip.upcase
    zona = zona.gsub(/\bBARRIO\b/, '').strip
    zona = zona.gsub(/\bZONA\b/, '').strip if zona

    return nil if zona == 'NO IDENTIFICADA' || zona == 'S/Z' || zona.nil?

    # Mapeo de combinaciones incorrectas a sus versiones correctas
    correcciones = {
      /\bSUD ESTE\b/i => 'SUDESTE',
      /\bSUD OESTE\b/i => 'SUDOESTE',
      /\bNORD ESTE\b/i => 'NORDESTE',
      /\bNORD OESTE\b/i => 'NOROESTE',
      /\bSUR ESTE\b/i => 'SUDESTE',
      /\bSUR OESTE\b/i => 'SUDOESTE',
      /\bNORTE ESTE\b/i => 'NORDESTE',
      /\bNORTE OESTE\b/i => 'NOROESTE',
      /\bSUD\b/i => 'SUR',
      /\bNORD\b/i => 'NORTE'
    }

    # Normalización de "VILLA 1ERO DE MAYO", "VILLA 1RO DE MAYO", "VILLA 1° DE MAYO"
    zona.gsub!(/\b1(?:ERO|RO|°)\b/, '1RO')

    # Reemplazo de "CENTRO" por "CENTRAL"
    zona.gsub!(/\bCENTRO\b/, 'CENTRAL')

    # Reemplazo de "VILLA NUEVO POTOSI" por "VILLA NUEVA POTOSI"
    zona.gsub!(/\bVILLA NUEVO POTOSI\b/, 'VILLA NUEVA POTOSI')

    # Aplicar las correcciones en la zona
    correcciones.each do |incorrecto, correcto|
      zona.gsub!(incorrecto, correcto) if zona.match?(incorrecto)
    end

    zona = zona[0..54].rpartition(' ').first.presence || zona[0..54] if zona.length > 60

    zona
  end

  def format_servicios(informacion_data)
    # Retornar `nil` si informacion_data no existe o no contiene "objetos_sociales"
    return nil unless informacion_data&.dig('datos', 'objetos_sociales')

    # Formatear los servicios
    servicios = informacion_data.dig('datos', 'objetos_sociales')
                                .map { |o| o['objetoSocial'] }
                                .join(', ')
                                .upcase.gsub(',', ', ')
                                .upcase.gsub(';', ', ').gsub(/ {2,}/, ' ')

    # Truncar a 500 caracteres en el último espacio
    servicios.length > 500 ? servicios[0..499].rpartition(' ').first : servicios
  end

  def fetch_data(url, id_seprec, skip_error = false)
    response = RestClient.get(url)
    JSON.parse(response.body)
  rescue RestClient::ExceptionWithResponse => e
    log("Error llamando a #{url}: #{e.response}", id_seprec) if skip_error
    skip_error ? JSON.parse(e.response.body) : {}
  rescue JSON::ParserError
    skip_error ? e.response.body : {}
  end

  def load_config
    YAML.load_file(CONFIG_PATH)
  end

  def save_config
    # Determinar el nuevo valor de `last`
    @config['last'] = @ultimo_id_exitoso unless @ultimo_id_exitoso.nil?
    # Guardar el valor actualizado en el archivo YAML
    File.open(CONFIG_PATH, 'w') { |f| f.write(@config.to_yaml) }
    log("Configuración guardada: Último ID procesado actualizado a #{@config['last']}")
  end

  def log(message, id_seprec = nil)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    seprec_info = id_seprec ? "[#{id_seprec}] " : ''
    @log.puts("[#{timestamp}]#{seprec_info}#{message}")
    puts "[#{timestamp}]#{seprec_info}#{message}"
  end

  def capitalize_words(name)
    name.split.map(&:capitalize).join(' ')
  end

  def format_razon_social(razon_social)
    return '' if razon_social.blank?

    razon_social
      .gsub('"', '')      # Elimina comillas dobles
      .gsub('.', '')      # Elimina puntos
      .gsub('-', '')      # Elimina guiones
      .gsub(/\s+/, ' ')   # Reemplaza múltiples espacios por uno solo
      .strip              # Elimina espacios al inicio y final
      .upcase             # Convierte todo a mayúsculas
  end

  def format_numero(empresa_data)
    texto = empresa_data.dig('datos', 'direccion', 'numeroDomicilio')&.upcase || ''
    return 's/n' if texto.gsub('Ú', 'U').match?(%r{SIN NUMERO|SN|S/N})

    texto
  end
end
