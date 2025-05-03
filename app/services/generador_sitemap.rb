require 'builder'

class GeneradorSitemap
  SITEMAP_NAMESPACE = 'http://www.sitemaps.org/schemas/sitemap/0.9'.freeze
  BASE_URL = Rails.configuration.base_url

  def self.generar
    ruta_sitemaps = Rails.root.join('public', 'sitemaps')
    Dir.mkdir(ruta_sitemaps) unless Dir.exist?(ruta_sitemaps)

    total = 0

    Ciudad.includes(:zonas, :comercios).find_each do |ciudad|
      next unless ciudad.comercios.activos.count >= 100

      fecha_hoy = Date.today.strftime('%Y-%m-%d')
      counter = 0
      nombre_archivo = "#{ciudad.ciudad.gsub(' ', '')}.xml"
      ruta_archivo = Rails.root.join('public', 'sitemaps', nombre_archivo)

      File.open(ruta_archivo, 'w') do |file|
        xml = Builder::XmlMarkup.new(target: file, indent: 2)
        xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
        xml.urlset(xmlns: SITEMAP_NAMESPACE) do
          # Nivel ciudad
          xml.url do
            xml.loc "#{BASE_URL}/Bolivia/#{ciudad.ciudad.parameterize}"
            xml.changefreq 'weekly'
            xml.lastmod fecha_hoy
          end
          counter += 1

          # Nivel zonas
          ciudad.zonas.each do |zona|
            xml.url do
              xml.loc "#{BASE_URL}/Bolivia/#{ciudad.ciudad.parameterize}/#{zona.descripcion.parameterize}"
              xml.changefreq 'weekly'
              xml.lastmod fecha_hoy
            end
            counter += 1
          end

          # Nivel comercios (ordenados por ID descendente)
          comercios_publicables = ComercioFilterService
              .new(ciudad_id: ciudad.id) # zona y texto no se aplican aquí
              .call
              .each do |comercio|
            xml.url do
              xml.loc "#{BASE_URL}/Bolivia/#{ciudad.ciudad.parameterize}/#{comercio.empresa.to_s.parameterize}"
              xml.changefreq 'weekly'
              xml.lastmod fecha_hoy
            end
            counter += 1
          end
        end
      end

      total += counter
      puts "#{counter} Registro Generados"
      puts "Sitemap generado: #{ruta_archivo}"
    end

    puts "#{total} TOTAL"
  end
end
