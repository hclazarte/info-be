class ComerciosController < ApplicationController
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
    where_conditions = build_where_conditions(params[:ciudad], params[:zona], params[:text])
    if where_conditions.blank?
      render json: { error: 'Debe proporcionar al menos uno de los parámetros: ciudad, zona o text.' }, status: :bad_request
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
    where_conditions = build_where_conditions(params[:ciudad], params[:zona], params[:text])
    if where_conditions.blank?
      return render json: { error: 'Debe proporcionar al menos uno de los parámetros: ciudad, zona o text.' }, status: :bad_request
    end

    # Calcular el offset
    offset = (page - 1) * per_page

    # Query SQL para obtener los comercios paginados
    sql = <<~SQL
      SELECT *
      FROM COMERCIOS
      WHERE #{where_conditions}
      OFFSET #{offset} ROWS
      FETCH NEXT #{per_page} ROWS ONLY
    SQL

    # Usar find_by_sql para mapear los resultados al modelo Comercio
    comercios = Comercio.find_by_sql(sql)

    # Obviar los campos shape y com_descr
    results = comercios.map do |comercio|
      comercio.attributes.except("shape", "com_descr")
    end

    # Retornar los resultados en JSON
    render json: {
      page: page,
      per_page: per_page,
      results: results
    }, status: :ok
  rescue => e
    render json: { error: "Error ejecutando la consulta: #{e.message}" }, status: :internal_server_error
  end

  private

  # Construir las condiciones WHERE dinámicamente
  def build_where_conditions(ciudad, zona, text)
    conditions = []

    # Procesar texto
    conditions.concat(process_words(text)) if text.present?

    # Procesar ciudad
    conditions.concat(process_words(ciudad)) if ciudad.present?

    # Procesar zona
    conditions.concat(process_words(zona)) if zona.present?

    # Combinar condiciones con AND
    conditions.join(' AND ')
  end

  # Procesar palabras y excluir las de la stop list
  def process_words(input)
    input.to_s.downcase.split.reject { |word| STOP_LIST.include?(word) }.map do |word|
      "TEXTO_OK(ID, '#{word}') = 'TRUE'"
    end
  end
end
