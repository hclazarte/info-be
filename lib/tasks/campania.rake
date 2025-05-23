namespace :campania do
  desc "Seleccionar comercios y enviar correos (opcional: rake campania:seleccionar[YYYY-MM-DD])"
  task :ejecutar, [:fecha] => :environment do |t, args|
    fecha = args[:fecha]

    if fecha
      puts "Reintentando campaña para la fecha: #{fecha}"
      CampaniaWorker.new.perform(fecha)
    else
      puts "Ejecutando nueva campaña sin fecha..."
      CampaniaWorker.new.perform
    end

    puts "Proceso completado."
  end
end
