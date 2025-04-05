class ComerciosController < ApplicationController
  include TokenAutenticable
  before_action :autorizar_comercio_por_token, only: [:update]

  STOP_LIST = %w[
    A B C D E F G H I J K L M N Ñ O P Q R S T U V W X Y Z Á É Í Ó Ú
    SR SRA SRES STA ACÁ AHÍ AJENA AJENAS AJENO AJENOS AL ALGO ALGUNA ALGUNAS
    ALGUNO ALGUNOS ALGÚN ALLÁ ALLÍ AQUEL AQUELLA AQUELLAS AQUELLO AQUELLOS
    AQUÍ CADA CIERTA CIERTAS CIERTO CIERTOS COMO CON CONMIGO CONSIGO CONTIGO
    CUALQUIER CUALQUIERA CUALQUIERAS CUAN CUANTA CUANTAS CUANTO CUANTOS CUÁN
    CUÁNTA CUÁNTAS CUÁNTO CUÁNTOS CÓMO DE DEJAR DEL DEMASIADA DEMASIADAS
    DEMASIADO DEMASIADOS DEMÁS EL ELLA ELLAS ELLOS ESA ESAS ESE ESOS ESTA
    ESTAR ESTAS ESTE ESTOS HACER HASTA JAMÁS JUNTO JUNTOS LA LAS LO LOS MAS
    ME MENOS MIENTRAS MISMA MISMAS MISMO MISMOS MUCHA MUCHAS MUCHO MUCHOS
    MUCHÍSIMA MUCHÍSIMAS MUCHÍSIMO MUCHÍSIMOS MUY MÁS MÍA MÍO NADA NI NINGUNA
    NINGUNAS NINGUNO NINGUNOS NO NOS NOSOTRAS NOSOTROS NUESTRA NUESTRAS
    NUESTRO NUESTROS NUNCA OS OTRA OTRAS OTRO OTROS PARA PARECER POCA POCAS
    POCO POCOS POR PORQUE QUE QUERER QUIEN QUIENES QUIENESQUIERA QUIENQUIERA
    QUIÉN QUÉ SER SI SIEMPRE SUYA SUYAS SUYO SUYOS SÍ SÍN TAL TALES TAN
    TANTA TANTAS TANTO TANTOS TE TENER TI TODA TODAS TODO TODOS TOMAR TUYA
    TUYO TÚ UN UNA UNAS UNOS USTED USTEDES VARIAS VARIOS VOSOTRAS VOSOTROS
    VUESTRA VUESTRAS VUESTRO VUESTROS Y YO ÉL
  ].map(&:downcase).freeze

  # GET /comercios/contar
  def contar
    where_conditions = build_where_conditions(params[:ciudad_id], params[:zona_id], params[:text])
    Rails.logger.info(where_conditions)
    if where_conditions.blank?
      render json: { error: 'Debe proporcionar al menos uno de los parámetros: ciudad_id, zona_id o text.' }, status: :bad_request
      return
    end

    sql = "SELECT COUNT(*) AS count FROM COMERCIOS WHERE #{where_conditions}"
    result_cursor = ActiveRecord::Base.connection.execute(sql)

    # Obtener el resultado del cursor
    result = result_cursor.fetch
    count = result ? result[0] : 0
    
    render json: { count: count }, status: :ok
  rescue => e
    render json: { error: "Error ejecutando la consulta: #{e.message}" }, status: :internal_server_error
  end

  # GET /comercios
  def lista
    # Parámetros de paginación
    page = params[:page].to_i > 0 ? params[:page].to_i : 1
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 10
  
    # Construcción de las condiciones WHERE
    where_conditions = build_where_conditions(params[:ciudad_id], params[:zona_id], params[:text])
    if where_conditions.blank?
      return render json: { error: 'Debe proporcionar al menos uno de los parámetros: ciudad_id, zona_id o text.' }, status: :bad_request
    end
  
    # Agregar condición para excluir personas naturales no autorizadas (autorizado = 1)
    where_conditions += " AND (persona_natural = 0 OR (persona_natural = 1 AND autorizado = 1))"
  
    # Calcular el offset
    offset = (page - 1) * per_page
  
    # Query SQL para contar los registros totales
    count_sql = "SELECT COUNT(*) AS count FROM COMERCIOS WHERE #{where_conditions}"
    count_cursor = ActiveRecord::Base.connection.execute(count_sql)
    total_count = count_cursor.fetch[0].to_i
  
    # Query SQL con selección explícita de campos requeridos y orden descendente por id
    sql = <<~SQL
      SELECT id, latitud, longitud, zona_nombre, calle_numero, empresa,
             servicios, telefono1, telefono2, telefono3
      FROM COMERCIOS
      WHERE #{where_conditions}
      ORDER BY id DESC
      OFFSET #{offset} ROWS
      FETCH NEXT #{per_page} ROWS ONLY
    SQL
  
    # Ejecutar y retornar
    results = ActiveRecord::Base.connection.exec_query(sql).to_a
  
    render json: {
      page: page,
      per_page: per_page,
      count: total_count,
      results: results
    }, status: :ok
  rescue => e
    render json: { error: "Error ejecutando la consulta: #{e.message}" }, status: :internal_server_error
  end

  def update
    if @comercio.update(comercio_params)
      render json: { message: 'Comercio actualizado correctamente' }
    else
      render json: { errors: @comercio.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def autorizar_comercio_por_token
    token = params[:token] || request.headers['Authorization']&.split('Bearer ')&.last
    solicitud = Solicitud.find_by(otp_token: token)
  
    @comercio = Comercio.find(params[:id])
  
    unless solicitud && solicitud.comercio_id == @comercio.id
      render json: { error: 'No autorizado para modificar este comercio' }, status: :unauthorized
    end
  end
  
  private
  
  def comercio_params
    params.require(:comercio).permit(
      :telefono1, :telefono2, :telefono3, :email, :pagina_web, :servicios,
      :contacto, :palabras_clave, :bloqueado, :activo, :horario, :latitud, :longitud,
      :zona_nombre, :calle_numero, :planta, :numero_local, :nit, :ciudad_id, :zona_id, 
      :autorizado, :documentos_validados
    )
  end  

  private

  # Construir condiciones WHERE dinámicamente
  def build_where_conditions(ciudad_id, zona_id, text)
    conditions = []
    
    # Obtener nombres de ciudad y zona si existen
    ciudad_nombre = get_ciudad_nombre(ciudad_id) if ciudad_id.present?
    zona_nombre = get_zona_nombre(zona_id) if zona_id.present?

    conditions << "CIUDAD_ID = #{ciudad_id.to_i}" if ciudad_id.present?
    conditions << "ZONA_ID = #{zona_id.to_i}" if zona_id.present?
    conditions << "ACTIVO = 1"
    conditions << "BLOQUEADO = 0"

    if text.present?
      clean_text = remove_city_and_zone(text, ciudad_nombre, zona_nombre)
      conditions.concat(process_words(clean_text))
    end

    conditions.join(' AND ')
  end

  # Procesar palabras y excluir las de la stop list
  def process_words(input)
    input.to_s.downcase.split.reject { |word| STOP_LIST.include?(word) }.map do |word|
      "TEXTO_OK(ID, '#{word}') = 'TRUE'"
    end
  end

  # Eliminar el nombre de la ciudad y la zona del texto
  def remove_city_and_zone(text, ciudad_nombre, zona_nombre)
    words = text.to_s.downcase.split
    words.reject! { |word| word == ciudad_nombre.to_s.downcase } if ciudad_nombre.present?
    words.reject! { |word| word == zona_nombre.to_s.downcase } if zona_nombre.present?
    words.join(' ')
  end

  # Métodos para obtener nombres de ciudad y zona
  def get_ciudad_nombre(ciudad_id)
    ciudad_id = ciudad_id.to_i
    return nil if ciudad_id.zero?
  
    begin
      ciudad = Ciudad.find_by(id: ciudad_id)
      if ciudad.nil?
        Rails.logger.error "Ciudad con ID #{ciudad_id} no encontrada"
        return nil
      end
      ciudad.nombre
    rescue => e
      Rails.logger.error "Error al obtener la ciudad: #{e.message}"
      nil
    end
  end  

  def get_zona_nombre(zona_id)
    zona_id = zona_id.to_i
    return nil if zona_id.zero?
  
    begin
      zona = Zona.find_by(id: zona_id)
      if zona.nil?
        Rails.logger.error "Zona con ID #{zona_id} no encontrada"
        return nil
      end
      zona.zona # Asegúrate de usar el nombre correcto de la columna
    rescue => e
      Rails.logger.error "Error al obtener la zona: #{e.message}"
      nil
    end
  end  
end
