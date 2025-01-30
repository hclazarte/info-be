class ZonificarComercios
  def self.ejecutar(ciudad_id)
    new(ciudad_id).procesar
  end

  def initialize(ciudad_id)
    @ciudad_id = ciudad_id
  end

  def procesar
    Rails.logger.info "Iniciando zonificación para ciudad ID: #{@ciudad_id}"
    zonas = obtener_zonas_elegibles
    Rails.logger.info "Zona elegibles encontradas: #{zonas.map { |z| z[:nombre] }}"
    zonas.each do |zona|
      Rails.logger.info "Coordenadas para zona #{zona[:nombre]}: #{zona[:comercios]}"
      zona_obj = Zona.find_or_create_by!(descripcion: zona[:nombre], ciudad_id: @ciudad_id)
      # poligono = generar_poligono(zona[:comercios])
      # if poligono.present?
      #   Rails.logger.info "Generando polígono para zona: #{zona[:nombre]}"
      #   guardar_poligono(zona_obj.id, poligono)
      # else
      #   Rails.logger.warn "No se pudo generar polígono para zona: #{zona[:nombre]}"
      # end
    end
    actualizar_zonas_id_por_texto
    # actualizar_zona_id_por_geometria
    actualizar_total_zonas
    # verificar_existencia_zonas_shape
  end

  private

  def obtener_zonas_elegibles
    zonas = Comercio.where(ciudad_id: @ciudad_id)
                    .where.not(latitud: nil, longitud: nil)
                    .group(:zona_nombre)
                    .having("COUNT(*) > 30 AND COUNT(latitud) >= 5 AND COUNT(longitud) >= 5")
                    .pluck(:zona_nombre, Arel.sql("XMLSERIALIZE(CONTENT XMLAGG(XMLELEMENT(e, longitud || ', ' || latitud || ', ') ORDER BY latitud, longitud).EXTRACT('//text()') AS CLOB)"))
                    .map { |zona_nombre, coordenadas| { nombre: zona_nombre, comercios: coordenadas.split(', ').reject(&:empty?) } }
    Rails.logger.info "Zonas filtradas: #{zonas.map { |z| z[:nombre] }}"
    zonas
  end

  def generar_poligono(coordenadas)
    return nil if coordenadas.size < 3
    coordenadas.flatten!
    coordenadas.push(coordenadas[0], coordenadas[1]) unless [coordenadas[-2], coordenadas[-1]] == [coordenadas[0], coordenadas[1]]
    poligono = "MDSYS.SDO_GEOMETRY(2003, 8307, NULL, MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 1), MDSYS.SDO_ORDINATE_ARRAY(" + coordenadas.join(', ') + "))"
    Rails.logger.info "Polígono generado: #{poligono}"
    poligono
  end

  def guardar_poligono(zona_id, poligono)
    return if poligono.nil? || poligono.empty?
    sql = "MERGE INTO zonas_shape zs USING (SELECT #{zona_id} AS id, #{poligono} AS shape FROM dual) src 
           ON (zs.id = src.id) 
           WHEN MATCHED THEN 
             UPDATE SET zs.shape = src.shape 
           WHEN NOT MATCHED THEN 
             INSERT (id, shape) VALUES (src.id, #{poligono})"
    Rails.logger.info "Ejecutando SQL: #{sql}"
    ActiveRecord::Base.connection.execute(sql)
  end

  def actualizar_zonas_id_por_texto
    sql = "UPDATE comercios c SET zona_id = (
      SELECT z.id FROM zonas z
      WHERE c.zona_nombre = z.descripcion AND c.ciudad_id = z.ciudad_id
    ) WHERE ciudad_id = #{@ciudad_id}"
    Rails.logger.info "Ejecutando actualización de zona_id en comercios por nombre de zona: #{sql}"
    ActiveRecord::Base.connection.execute(sql)
  end

  def actualizar_zona_id_por_geometria
    sql = "UPDATE comercios c SET zona_id = (
      SELECT cs.id FROM comercios_shape cs, zonas_shape zs 
      WHERE SDO_RELATE(cs.shape, zs.shape, 'mask=inside') = 'TRUE'
    ) WHERE ciudad_id = #{@ciudad_id}"
    Rails.logger.info "Ejecutando actualización de zona_id en comercios por geometría: #{sql}"
    ActiveRecord::Base.connection.execute(sql)
  end

      def actualizar_total_zonas
    Zona.where(ciudad_id: @ciudad_id).find_each do |zona|
      total_comercios = Comercio.where(zona_id: zona.id).count
      zona.update!(total: total_comercios)
    end
    Rails.logger.info "Actualización de total en zonas completada"
  end

  def aplicar_convex_hull
    sql = "UPDATE zonas_shape SET SHAPE = (
      SELECT SDO_GEOM.SDO_CONVEXHULL(c.shape, m.diminfo) 
      FROM zonas_shape c, user_sdo_geom_metadata m 
      WHERE m.table_name = 'ZONAS_SHAPE' AND m.column_name = 'SHAPE' 
      AND zonas_shape.ID = c.ID AND c.ID IN (SELECT id FROM zonas WHERE ciudad_id = #{@ciudad_id}))"
    Rails.logger.info "Aplicando CONVEX HULL a zonas_shape para ciudad ID: #{@ciudad_id}: #{sql}"
    ActiveRecord::Base.connection.execute(sql)
  end

  def verificar_existencia_zonas_shape
    count = ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM zonas_shape")
    Rails.logger.info "Cantidad de registros en zonas_shape después de la actualización: #{count}"
  end
end
