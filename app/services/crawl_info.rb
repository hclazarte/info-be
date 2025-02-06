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
  end

  def run
    log("INICIO DE SINCRONIZACIÓN")
    @stat_5 = 0

    (@last_id + 1).upto(@last_id + @step) do |id|
      begin
        process_id(id)
      rescue => e
        log("Error procesando #{e.message}",id)
        @stat_5 += 1
      end
    end
    @last_id = @last_id + @step

    save_config
    log("FIN DE SINCRONIZACIÓN")
    @log.close
  end

  private

  # Procesar ID específico
  def process_id(id_seprec)
    activo = true;
    empresa_data = fetch_data("https://servicios.seprec.gob.bo/api/empresas/#{id_seprec}", id_seprec)
    return log("Empresa no encontrada", id_seprec) unless empresa_data
    return log("Error procesando comercio en estado #{empresa_data.dig("datos", "estado").to_s}", id_seprec) if (empresa_data.dig("datos", "estado").to_s != 'ACTIVO')

    establecimientos_data = fetch_data("https://servicios.seprec.gob.bo/api/empresas/#{id_seprec}/establecimientos", id_seprec)
    return log("Establecimientos no encontrados",id_seprec) if establecimientos_data.empty?

    id_est = establecimientos_data.dig("datos", "filas", 0, "id")
    
    informacion_data = fetch_data("https://servicios.seprec.gob.bo/api/empresas/informacionBasicaEmpresa/#{id_seprec}/establecimiento/#{id_est}", id_seprec, true)
    activo = false unless informacion_data && informacion_data["mensaje"] != "No se encontró la empresa o esta inactiva."
    process_comercio(id_seprec, id_est, empresa_data, establecimientos_data, informacion_data, activo)

    # Actualizar la última fecha procesada
    fecha_inscripcion = DateTime.parse(empresa_data.dig("datos", "fechaInscripcion")) rescue nil
    @ultima_fecha = fecha_inscripcion if fecha_inscripcion && (!@ultima_fecha || fecha_inscripcion > @ultima_fecha)
  end

  def process_comercio(id_seprec, id_est, empresa_data, establecimientos_data, informacion_data, activo)
    begin
      # Paso 1: Buscar el comercio existente o inicializar uno nuevo
      comercio = Comercio.where(seprec: id_seprec, seprec_est: id_est).first
      comercio ||= Comercio.new(seprec: id_seprec, seprec_est: id_est)
  
      # Paso 2: Asignar atributos
      comercio.latitud = empresa_data.dig("datos", "direccion", "latitud")
      comercio.longitud = empresa_data.dig("datos", "direccion", "longitud")
      comercio.fecha_registro ||= DateTime.now
      comercio.fecha_encuesta = DateTime.parse(empresa_data.dig("datos","fechaInscripcion"))
      comercio.zona_nombre = format_zona(empresa_data)
      comercio.fundempresa = empresa_data.dig("datos","matriculaAnterior")
      #comercio.numero_comercio 
      comercio.calle_numero = "#{empresa_data.dig('datos', 'direccion', 'nombreVia')} Nº #{format_numero(empresa_data)}"
      #comercio.planta = empresa_data.dig("datos", "direccion", "piso")
      #comercio.numero_local = empresa_data.dig("datos", "direccion", "numeroNombreAmbiente")
      contacto_telefono = informacion_data&.dig("datos", "contactos")&.find { |c| c["tipoContacto"] == "TELEFONO" } || nil
      comercio.telefono1 = contacto_telefono.dig("descripcion", 0, "numero") if contacto_telefono
      #comercio.horario
      comercio.observacion = "SEPREC:" + (activo ? " ACTIVANDO" : " DESACTIVANDO")
      comercio.empresa = format_razon_social(empresa_data.dig("datos", "razonSocial"))
      #comercio.observacion2
      contacto_correo = informacion_data&.dig("datos", "contactos")&.find { |c| c["tipoContacto"] == "CORREO" } || nil 
      comercio.email = contacto_correo.dig("descripcion", 0, "correo") if contacto_correo
      #comercio.pagina_web
      comercio.servicios = format_servicios (informacion_data)
      #activo
      comercio.activo = activo
      #comercio.ofertas
      comercio.nit = empresa_data.dig("datos","nit")
      
      # Paso 3: Asociar la ciudad, crearla si no existe
      cod_municipio = empresa_data.dig("datos", "direccion", "codMunicipio")
      ciudad = Ciudad.find_or_create_by(
        cod_municipio: cod_municipio,
        cod_pais: "BO" # País fijo como "Bolivia"
      ) do |new_ciudad|
        # Solo se ejecuta si se crea una nueva ciudad
        new_ciudad.ciudad = capitalize_words(empresa_data.dig("datos", "direccion", "municipio", "descripcion"))
        new_ciudad.pais = "Bolivia"
      end
      
      comercio.ciudad = ciudad
  
      # Paso 4: Guardar el comercio
      if comercio.save
        log("Comercio procesado: #{comercio.empresa}", id_seprec)
      else
        log("Error guardando comercio: #{comercio.errors.full_messages.join(', ')}", id_seprec)
      end
    rescue => e
      log("Error procesando comercio: #{e.message}", id_seprec)
    end
  end  

  # Métodos Auxiliares
  
  def format_zona(empresa_data)
    zona = empresa_data.dig("datos", "direccion", "nombreSubdivisionGeografica")&.gsub('.', '').gsub('-', '')&.strip
    return nil if zona&.upcase == 'NO IDENTIFICADA' || zona&.upcase == 'S/Z'
  
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
  
    # Aplicar las correcciones en la zona
    correcciones.each do |incorrecto, correcto|
      zona.gsub!(incorrecto, correcto) if zona&.match?(incorrecto)
    end
  
    zona
  end   
  
  def format_servicios(informacion_data)
    # Retornar `nil` si informacion_data no existe o no contiene "objetos_sociales"
    return nil unless informacion_data&.dig("datos", "objetos_sociales")
  
    # Formatear los servicios
    servicios = informacion_data.dig("datos", "objetos_sociales")
                               .map { |o| o["objetoSocial"] }
                               .join(", ")
                               .upcase.gsub(',', ', ')
                               .upcase.gsub(';', ', ').gsub(/ {2,}/, " ")
                            
                               # Truncar a 500 caracteres en el último espacio
    servicios.length > 500 ? servicios[0..499].rpartition(" ").first : servicios
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
    @config['last'] = if @ultima_fecha && (DateTime.now - @ultima_fecha).to_i < 5
                        0 # Reinicia a 0 si la última fecha procesada es menor a 5 días atrás
                      elsif @stat_5 && (@stat_5 > @step * 0.8 && @step > 1000)
                        0 # Reinicia a 0 si más del 80% son registros inexistentes y el paso es grande
                      else
                        @last_id # Mantiene el último ID procesado
                      end
  
    # Guardar el valor actualizado en el archivo YAML
    File.open(CONFIG_PATH, 'w') { |f| f.write(@config.to_yaml) }
    log("Configuración guardada: Último ID procesado actualizado a #{@config['last']}")
  end 

  def log(message, id_seprec = nil)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    seprec_info = id_seprec ? "[#{id_seprec}] " : ""
    @log.puts("[#{timestamp}]#{seprec_info}#{message}")
    puts "[#{timestamp}]#{seprec_info}#{message}"
  end  

  def capitalize_words(name)
    name.split.map(&:capitalize).join(' ')
  end

  def format_razon_social(razon_social)
    return "" if razon_social.blank?
  
    razon_social
      .gsub('"', '')      # Elimina comillas dobles
      .gsub('.', '')      # Elimina puntos
      .gsub('-', '')      # Elimina guiones
      .gsub(/\s+/, ' ')   # Reemplaza múltiples espacios por uno solo
      .strip              # Elimina espacios al inicio y final
      .upcase             # Convierte todo a mayúsculas
  end

  def format_numero(empresa_data)
    texto = empresa_data.dig('datos', 'direccion', 'numeroDomicilio')&.upcase || ""
    return 's/n' if texto.gsub('Ú', 'U').match?(/SIN NUMERO|SN|S\/N/)
    
    texto
  end  
end