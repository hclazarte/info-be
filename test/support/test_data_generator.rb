# test/support/test_data_generator.rb
class TestDataGenerator
  # Convierte un offset relativo en fecha/hora absoluta
  # Ej: "+30d", "-2h", "+15m"
  def self.testdate_offset(offset_str)
    return nil if offset_str.blank?

    case offset_str
    when /^([+-]\d+)d$/
      Date.today + Regexp.last_match(1).to_i
    when /^([+-]\d+)h$/
      Time.current + Regexp.last_match(1).to_i.hours
    when /^([+-]\d+)m$/
      Time.current + Regexp.last_match(1).to_i.minutes
    else
      raise ArgumentError, "Formato de offset inválido: #{offset_str}"
    end
  end

  # Recorre un hash de atributos y resuelve los campos *_testdate_offset,
  # en el futuro se podrán agregar más tipos (ej. *_password_fake, *_email_fake).
  def self.apply_testdata(attrs)
    attrs.each_with_object({}) do |(k, v), result|
      case k.to_s
      when /_testdate_offset$/
        base_name = k.to_s.sub(/_testdate_offset$/, "")
        result[base_name] = testdate_offset(v)
      else
        result[k] = v
      end
    end
  end
end
