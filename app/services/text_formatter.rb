# app/services/text_formatter.rb
class TextFormatter
  class << self
    # Normaliza la razón social:
    # 1. Elimina tildes y caracteres especiales → ASCII
    # 2. Quita comillas, puntos, comas y guiones
    # 3. Colapsa espacios múltiples y recorta extremos
    # 4. Devuelve la cadena en MAYÚSCULAS
    def normalizar_razon_social(texto)
      return '' if texto.blank?

      I18n.transliterate(texto.to_s)   # «Ñandú S.A.» → «Nandu S.A.»
        .gsub('"', '')                 # sin comillas
        .gsub('.', '')                 # sin puntos
        .gsub(',', '')                 # sin comas
        .gsub('-', '')                 # sin guiones
        .gsub(/\s+/, ' ')              # un solo espacio
        .strip                         # quita espacios extremos
        .upcase                        # todo a mayúsculas
    end

    # Futuras normalizaciones irán aquí...
    # def normalizar_direccion(...)
    # end
  end
end
