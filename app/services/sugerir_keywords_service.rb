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

  STOPWORDS = %w[
    a al algo algun alguna algunos algunas ante antes aquel aquella aquello aquellas aquellos
    como con contra cual cuales cuando de del desde donde dos e el ella ellas ellos en entre
    es esa esas ese esos esta estas este estos fue ha han hasta la las le les lo los mas mi
    muy ni no o os para pero por que se sin sobre su sus te un una uno y ya por con para
  ].freeze

  def self.norm(s)
    ActiveSupport::Inflector.transliterate(s.to_s).downcase.strip
  end

  def self.tokens_from_text(s)
    s.to_s.downcase.scan(/[[:alpha:]\p{M}]+/u)
  end

  def self.exclusion_tokens_from(payload)
    base = []
    base += tokens_from_text(payload["empresa"])
    base += tokens_from_text(payload["servicios"])
    base.map { |t| norm(t) }.uniq
  end

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
    empresa_txt   = p["empresa"].to_s
    servicios_txt = p["servicios"].to_s

    <<~PROMPT
    Eres un generador de marketing local. Devuelve SOLO JSON con esta forma exacta:
    { "keywords": string, "ofertas": string }

    Reglas estrictas para "keywords":
    - Debe generar variantes derivadas, sinónimos y términos relacionados de las palabras incluidas en "empresa" y "servicios". Ejemplo: "geografía" → "geográfico", "georreferenciado", "geolocalización", "mapas", "cartografía".
    - Una sola cadena con múltiples términos separados por espacio (sin comas ni saltos).
    - Evita preposiciones y palabras vacías (de, la, en, por, con, y, o, a, un, una, para, etc.).
    - NO incluyas ninguna palabra exacta presente en:
        * empresa: "#{empresa_txt}"
        * servicios: "#{servicios_txt}"
      (Evita exactamente esas palabras base; ignora mayúsculas/acentos al comparar).
    - En lugar de las palabras excluidas, genera:
        * Derivaciones morfológicas y de familia léxica (p. ej., “geográfico” ⇢ geografía, geógrafo, geolocalizado; “marketing” ⇢ marketinero, mercadotecnia).
        * Sinónimos en español de uso común 
        * Expresines que puedan reemplazar la palabra (p. ej., "chalet" ⇢ "casa de campo", "villa de verano"; "hogar" ⇢ "casa de familia", "domicilio familiar")
        * Equivalentes en inglés o préstamos frecuentes en español (p. ej., “websites”, “digital marketing”, “dev”, “local seo”).
        * Variantes geográficas (barrios, gentilicios, adjetivos locales), si hay ubicación.
    - Mezcla con términos de intención (p. ej., “cerca”, “servicio técnico”, “agencia”, “tienda”), siempre que no sean stopwords.
    - Longitud objetivo: 20..100 términos (tokens) resultantes, separados por espacio.

    Reglas para "ofertas":
    - En el campo "ofertas", liste los servicios o productos permanentes que ofrece la empresa, sin incluir promociones temporales ni frases de descuento. Ejemplo: "Alojamiento Web", "Diseño de Sitios Web", "Optimización SEO", "Publicidad en Google Ads".
    - Una sola cadena con 2 o 3 frases cortas separadas por ", " (coma + espacio).
    - Máximo 4 palabras por frase; solo letras españolas y espacios; todo en minúsculas.

    No incluyas ningún otro campo.

    Contexto (fuente de ideas):
    empresa: #{empresa_txt}
    servicios: #{servicios_txt}
    tipo: #{Array(p["tipo"]).join(", ")}
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
    exclusion = exclusion_tokens_from(payload) # palabras exactas a excluir (normalizadas)

    # --- KEYWORDS ---
    # 1) split por espacios (modelo puede devolver expresiones con espacios; aquí ya vienen como tokens separados)
    terms = split_terms(data[:keywords]).map(&:strip).reject(&:empty?)

    # 2) limpieza: sin duplicados, longitud > 2
    terms = terms.uniq.select { |t| t.length > 2 }

    # 3) excluir exactos de empresa/servicios (case/tildes ignorados)
    terms = terms.reject { |t| exclusion.include?(norm(t)) }

    # 4) quitar stopwords dentro de expresiones (si el modelo devolvió "casa de campo" ⇒ "casa", "campo")
    #    Nota: como la salida final es una sola cadena separada por espacios, tratamos cada palabra individualmente.
    terms = terms.reject { |t| STOPWORDS.include?(t.downcase) }

    # 5) priorización por "promocionar_ahora"
    if pri.any?
      prio, rest = terms.partition { |t| pri.any? { |s| t.downcase.include?(s) } }
      terms = (prio + rest).uniq
    end

    data[:keywords] = terms.join(" ")

    # --- OFERTAS (mantienes tu normalización rígida de ≤4 palabras por frase) ---
    ofertas_raw = data[:ofertas].to_s.dup
    unless ofertas_raw.include?(",")
      palabras = ofertas_raw.strip.split(/\s+/)
      frases = []
      palabras.each_slice(4) { |slice| frases << slice.join(" ") }
      ofertas_raw = frases.join(", ")
    end

    frases = ofertas_raw.split(",").map(&:strip).reject(&:empty?).map do |fr|
      limpio = fr.gsub(/[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s]/, " ").gsub(/\s+/, " ").strip.downcase
      palabras = limpio.split(/\s+/).reject { |w| STOPWORDS.include?(w) }.first(4)
      palabras.join(" ")
    end

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
