namespace :campania do
  desc "Seleccionar comercios y enviar correos"
  task seleccionar: :environment do
    puts "Iniciando selección de comercios para campaña..."
    CampaniaSeleccionadorWorker.new.perform
    puts "Proceso completado."
  end
end
