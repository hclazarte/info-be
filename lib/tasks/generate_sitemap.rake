# lib/tasks/generate_sitemap.rake

namespace :sitemap do
  desc "Generar los sitemaps para las ciudades"
  task generate: :environment do
    begin
      puts "Iniciando generación de sitemaps..."
      GeneradorSitemap.generar
      puts "Generación de sitemaps completada."
    rescue StandardError => e
      puts "Error al generar sitemaps: #{e.message}"
      puts e.backtrace.join("\n")
      exit 1
    end
  end
end
