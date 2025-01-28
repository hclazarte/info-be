require 'builder'

class GeneradorSitemap
  SITEMAP_NAMESPACE = "http://www.sitemaps.org/schemas/sitemap/0.9"
  BASE_URL = Rails.env.production? ? "https://infomovil.com.bo" : "https://dev.infomovil.com.bo"

  def self.generar
    # Generar sitemaps por ciudades
    Ciudad.includes(:zonas, :comercios).find_each do |ciudad|
      next unless ciudad.comercios.count >= 100 # Solo para ciudades con 100 o más comercios

      nombre_archivo = "#{ciudad.ciudad.gsub(' ', '')}.xml"
      ruta_archivo = Rails.root.join("public", "sitemaps", nombre_archivo)

      File.open(ruta_archivo, 'w') do |file|
        xml = Builder::XmlMarkup.new(target: file, indent: 2)
        xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
        xml.urlset(xmlns: SITEMAP_NAMESPACE) do
          # Nivel ciudad
          xml.url do
            xml.loc "#{BASE_URL}/Bolivia/#{ciudad.ciudad.gsub(' ', '-') }"
            xml.changefreq "weekly"
          end

          # Nivel zonas
          ciudad.zonas.each do |zona|
            xml.url do
              xml.loc "#{BASE_URL}/Bolivia/#{ciudad.ciudad.gsub(' ', '-')}/#{zona.descripcion.gsub(' ', '-')}"
              xml.changefreq "weekly"
            end
          end

          # Nivel comercios
          ciudad.comercios.where(persona_natural: 'FALSE').each do |comercio|
            xml.url do
              xml.loc "#{BASE_URL}/Bolivia/#{ciudad.ciudad.gsub(' ', '-')}/#{comercio.empresa.downcase.gsub(' ', '-')}"
              xml.changefreq "weekly"
            end
          end
        end
      end

      puts "Sitemap generado: #{ruta_archivo}"
    end
  end
end

# Ejecución del servicio
GeneradorSitemap.generar
