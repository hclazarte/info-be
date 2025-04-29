namespace :campania do
  desc "Seleccionar comercios para la campaña de correos"
  task seleccionar: :environment do
    puts "Iniciando selección de comercios para campaña..."
    CampaniaSeleccionador.seleccionar_comercios
    puts "Selección de comercios completada."
  end
end
