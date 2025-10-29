# frozen_string_literal: true

class SugerirKeywordsService
  # Documentación actualizada: el proveedor debe devolver SOLO:
  # { "keywords": String, "ofertas": String }
  #
  # - keywords: una sola cadena con 8..20 términos separados por espacio (sin preposiciones).
  # - ofertas: una sola cadena con 2 o 3 frases cortas separadas por comas.

  class Error < StandardError; end
  class ProviderError < Error; end
  class InvalidResponse < Error; end

  def self.call(payload, model: :"gpt-4.1-mini")
    prompt = build_prompt(payload)

    resp = OpenAIClient.responses.create(
      model: model,
      input: prompt,
      text: { format: { type: "json_object" } },
      temperature: 0.4
    )

    data = parse_json(resp)
    validate!(data)
    postprocess(data, payload)
  rescue OpenAI::Errors::APIError, OpenAI::Errors::RateLimitError => e
    raise ProviderError, e.message
  end

  def self.build_prompt(p)
    <<~PROMPT
    Eres un generador de marketing local. Devuelve SOLO JSON con esta forma exacta:
    { "keywords": string, "ofertas": string }

    Reglas estrictas:
    - "keywords": una sola cadena con múltiples combinaciones de búsqueda separadas por espacio.
      * Evita preposiciones y palabras vacías (de, la, en, por, con, y, o, a, un, una, para, etc.).
      * Incluye términos relevantes al rubro y la ubicación.
      * Incluye palabras en ingles que son sinónimos o que son utilizados en español
      * Longitud objetivo: entre 8 y 20 combinaciones (separadas por espacio).
    - "ofertas": una sola cadena con una o más frases cortas separadas por comas.
      * Cada frase debe tener **máximo 4 palabras**.
      * Reescribe cualquier frase que exceda 4 palabras para que cumpla el límite.
      * Usa **solo** letras del alfabeto español y espacios (sin números, signos, ni "/").
      * Formato: palabras en minúsculas, separa frases solo con ", " (coma y espacio).
    - No incluyas ningún otro campo.

    Contexto:
    negocio: #{p["negocio"]}
    tipo: #{Array(p["tipo"]).join(", ")}
    rubro: #{p["rubro"]}
    top_servicios: #{Array(p["top_servicios"]).join(", ")}
    promocionar_ahora: #{Array(p["promocionar_ahora"]).join(", ")}
    marcas_permitidas: #{Array(p["marcas"]).join(", ")}
    ubicacion: #{Array(p["ubicacion"]).join(" > ")}
    diferenciadores: #{Array(p["diferenciadores"]).join(", ")}
    publico_objetivo: #{Array(p["publico_objetivo"]).join(", ")}
    PROMPT
  end

  def self.parse_json(resp)
    raw = resp&.output_text
    data = JSON.parse(raw, symbolize_names: true)

    # Robustez: si el modelo devolviera arrays por error, conviértelos a string.
    if data[:keywords].is_a?(Array)
      data[:keywords] = data[:keywords].join(" ")
    end
    if data[:ofertas].is_a?(Array)
      data[:ofertas] = data[:ofertas].join(", ")
    end

    data
  rescue JSON::ParserError
    raise InvalidResponse, "Formato JSON inválido del proveedor"
  end

  def self.validate!(data)
    unless data[:keywords].is_a?(String) && !data[:keywords].strip.empty?
      raise InvalidResponse, "keywords faltan"
    end

    unless data[:ofertas].is_a?(String) && !data[:ofertas].strip.empty?
      raise InvalidResponse, "ofertas faltan"
    end

    data
  end

  def self.postprocess(data, payload)
    pri = Array(payload["promocionar_ahora"]).map { |s| s.to_s.downcase }.reject(&:empty?)

    # --- KEYWORDS (igual que ya tienes) ---
    terms = split_terms(data[:keywords])
    terms = terms.map(&:strip).reject(&:empty?).uniq

    if pri.any?
      prio, rest = terms.partition do |t|
        td = t.downcase
        pri.any? { |s| td.include?(s) }
      end
      terms = (prio + rest).uniq
    end
    data[:keywords] = terms.join(" ")

    # --- OFERTAS (normalización dura máx. 4 palabras por frase) ---
    ofertas_raw = data[:ofertas].to_s.dup

    # Si no hay comas, segmenta en grupos de hasta 4 palabras
    unless ofertas_raw.include?(",")
      palabras = ofertas_raw.strip.split(/\s+/)
      frases = []
      palabras.each_slice(4) { |slice| frases << slice.join(" ") }
      ofertas_raw = frases.join(", ")
    end

    # Divide por comas, limpia caracteres, recorta a 4 palabras, deduplica
    frases = ofertas_raw.split(",").map { |s| s.strip }.reject(&:empty?).map do |fr|
      # Mantén solo letras del español y espacios
      limpio = fr.gsub(/[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s]/, " ")
                .gsub(/\s+/, " ")
                .strip
                .downcase

      # Recorta a máximo 4 palabras
      palabras = limpio.split(/\s+/).first(4)
      palabras.join(" ")
    end

    # Elimina vacías y duplicadas, y vuelve a unir con ", "
    frases = frases.reject(&:empty?).uniq
    data[:ofertas] = frases.join(", ")

    data
  end

  # Helpers
  def self.split_terms(str)
    # Divide por uno o más espacios y colapsa espacios múltiples
    str.to_s.strip.split(/\s+/)
  end
end
