# app/services/comercio_filter_service.rb
class ComercioFilterService
  # Reutilizamos la lista de palabras vacías definida en el controlador.
  # Se puede aislar, moverla a un módulo compartido y referenciarlo aquí.
  STOP_LIST = ComerciosController::STOP_LIST

  def initialize(ciudad_id: nil, zona_id: nil, text: nil)
    @ciudad_id = ciudad_id.presence
    @zona_id   = zona_id.presence
    @text = text.to_s.gsub('-', ' ')
  end

  # Devuelve un ActiveRecord::Relation listo para encadenar (paginación, select, order…)
  def call
    scope = Comercio
              .where(activo: 1, bloqueado: 0)
              .where('seprec IS NOT NULL OR autorizado = 1')
              .where('persona_natural = 0 OR (persona_natural = 1 AND autorizado = 1)')

    scope = scope.where(ciudad_id: @ciudad_id) if @ciudad_id
    scope = scope.where(zona_id:   @zona_id)   if @zona_id
    scope = apply_text_filter(scope)           if @text.present?

    scope.order(id: :desc)
  end

  private

  # ——————————————————————————————————————————————
  # FILTRO POR TEXTO (CONTAINS + STOP‑LIST)
  # ——————————————————————————————————————————————
  def apply_text_filter(scope)
    ciudad_nombre = nombre_ciudad(@ciudad_id)
    zona_nombre   = nombre_zona(@zona_id)

    clean_text = remove_city_and_zone(@text, ciudad_nombre, zona_nombre)
    text_clauses = process_words(clean_text)

    return scope if text_clauses.empty?

    scope.where(text_clauses.join(' AND '))
  end

  # Excluye palabras vacías y construye las cláusulas CONTAINS(...)
  def process_words(input)
    input.to_s.downcase.split
         .reject { |w| STOP_LIST.include?(w) }
         .map    { |w| "CONTAINS(COM_DESCR, BUSQUEDA('#{w}')) > 0" }
  end

  def remove_city_and_zone(text, ciudad_nombre, zona_nombre)
    words = text.to_s.downcase.split
    words -= [ciudad_nombre.to_s.downcase] if ciudad_nombre
    words -= [zona_nombre.to_s.downcase]   if zona_nombre
    words.join(' ')
  end

  # Helpers para obtener nombres (sin alterar modelos existentes)
  def nombre_ciudad(id)
    return unless id
    Ciudad.find_by(id: id)&.ciudad
  rescue StandardError
    nil
  end

  def nombre_zona(id)
    return unless id
    Zona.find_by(id: id)&.descripcion
  rescue StandardError
    nil
  end
end
