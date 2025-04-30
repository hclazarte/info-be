# app/services/ciudad_detectada_por_ip.rb
class CiudadDetectadaPorIp
  def self.buscar(ip)
    return nil if ip.blank?

    return nil if ip.include?('190.181.25.130') ||
                  ip.start_with?('192.168.0') ||
                  ip.include?('127.0.0.1') ||
                  ip.include?('::1')

    ipinfodb_key = ENV['IPINFODB_KEY'] || 'default_fallback_key'
    url = "http://api.ipinfodb.com/v3/ip-city/?key=#{ipinfodb_key}&ip=#{ip}"

    begin
      response = Faraday.get(url)

      if response.status == 200
        ip_info = response.body.split(';')
        ciudad_nombre = ip_info[5]&.upcase

        if ciudad_nombre.present?
          return Ciudad.where('UPPER(ciudad) LIKE ?', "%#{ciudad_nombre}%").first
        end
      end
    rescue Faraday::Error => e
      Rails.logger.error "Error al obtener IP info: #{e.message}"
    end

    nil
  end
end
