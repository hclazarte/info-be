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

    (@last_id + 1).upto(@last_id + @step) do |id|
      begin
        process_id(id)
      rescue => e
        log("Error procesando #{e.message}",id)
      end
    end

    save_config
    log("FIN DE SINCRONIZACIÓN")
    @log.close
  end

  private

  # Procesar ID específico
  def process_id(id_seprec)
    empresa_data = fetch_data("https://servicios.seprec.gob.bo/api/empresas/#{id_seprec}", id_seprec)
    return log("Empresa no encontrada", id_seprec) unless empresa_data

    establecimientos_data = fetch_data("https://servicios.seprec.gob.bo/api/empresas/#{id_seprec}/establecimientos", id_seprec)
    return log("Establecimientos no encontrados",id_seprec) if establecimientos_data.empty?

    id_est = establecimientos_data.dig("datos", "filas", 0, "id")

    informacion_data = fetch_data("https://servicios.seprec.gob.bo/api/empresas/informacionBasicaEmpresa/#{id_seprec}/establecimiento/#{id_est}", id_seprec)
    return log("Información no encontrada",id_seprec) unless informacion_data

    process_comercio(id_seprec, id_est, empresa_data, establecimientos_data, informacion_data)
  end

  def process_comercio(id_seprec, id_est, empresa_data, establecimientos_data, informacion_data)
    begin
      # Paso 1: Buscar el comercio existente o inicializar uno nuevo
      comercio = Comercio.where(seprec: id_seprec, seprec_est: id_est).first
      comercio ||= Comercio.new(seprec: id_seprec, seprec_est: id_est)
  
      # Paso 2: Asignar atributos
      comercio.latitud = empresa_data.dig("datos", "direccion", "latitud")
      comercio.longitud = empresa_data.dig("datos", "direccion", "longitud")
      comercio.fecha_registro ||= DateTime.now
      comercio.fecha_encuesta = DateTime.parse(empresa_data.dig("datos","fechaInscripcion"))
      comercio.zona_nombre = empresa_data.dig("datos", "direccion", "nombreSubdivisionGeografica")
      comercio.fundempresa = empresa_data.dig("datos","matriculaAnterior")
      #comercio.numero_comercio 
      comercio.calle_numero = "#{empresa_data.dig('datos', 'direccion', 'nombreVia')} Nº #{empresa_data.dig('datos', 'direccion', 'numeroDomicilio')}"
      #comercio.planta = empresa_data.dig("datos", "direccion", "piso")
      #comercio.numero_local = empresa_data.dig("datos", "direccion", "numeroNombreAmbiente")
      contacto_telefono = informacion_data.dig("datos", "contactos")&.find { |c| c["tipoContacto"] == "TELEFONO" }
      comercio.telefono1 = contacto_telefono.dig("descripcion", 0, "numero") if contacto_telefono
      #comercio.horario
      #comercio.observacion
      comercio.empresa = format_razon_social(empresa_data.dig("datos", "razonSocial"))
      #comercio.observacion2
      contacto_correo = informacion_data.dig("datos", "contactos")&.find { |c| c["tipoContacto"] == "CORREO" }
      comercio.email = contacto_correo.dig("descripcion", 0, "correo") if contacto_correo
      #comercio.pagina_web
      # Procesar los servicios
      servicios = informacion_data.dig("datos", "objetos_sociales")&.map { |o| o["objetoSocial"] }&.join(", ").gsub(/ {2,}/, " ")
      if servicios && servicios.length > 500
        # Truncar al último espacio antes de los 500 caracteres
        servicios = servicios[0, 500].rpartition(' ').first
      end
      comercio.servicios = servicios
      #comercio.ofertas
      
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
  def fetch_data(url, id_seprec)
    response = RestClient.get(url)
    JSON.parse(response.body)
  rescue RestClient::ExceptionWithResponse => e
    log("Error llamando a #{url}: #{e.response}", id_seprec)
    {}
  end

  def load_config
    YAML.load_file(CONFIG_PATH)
  end

  def save_config
    @config['last'] = @last_id
    File.open(CONFIG_PATH, 'w') { |f| f.write(@config.to_yaml) }
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
end