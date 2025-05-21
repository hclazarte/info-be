# lib/tasks/email_verificado.rake

namespace :propietarios do
  desc "Actualiza el campo email_verificado a 1 para correos válidos"
  task actualizar_email_verificado: :environment do
    umbral_fecha = 2.days.ago.to_date

    puts "[#{Time.now}] Iniciando actualización de email_verificado..."
    puts "Buscando correos enviados antes del #{umbral_fecha}, sin rebote y con email_verificado = NUll"

    emails_candidatos = CampaniaPropietariosEmail
      .where("ultima_fecha_envio <= ?", umbral_fecha)
      .where(email_rebotado: 0)
      .pluck(:email)
      .uniq

    puts "Se encontraron #{emails_candidatos.count} correos candidatos. Verificando tramitadores..."

    emails_validos = emails_candidatos.reject do |email|
      cantidad = Comercio.where(email: email).count
      if cantidad > 5
        puts "Descartado como tramitador: #{email} (presente en #{cantidad} comercios)"
        true
      else
        false
      end
    end

    emails_actualizados = []

    emails_validos.each do |email|
      actualizados = Comercio
        .where(email: email)
        .where("email_verificado IS NULL")
        .update_all(email_verificado: email)

      if actualizados > 0
        emails_actualizados << email
        puts "[#{Time.now}] #{actualizados} registro(s) actualizado(s) para el correo: #{email}"
      end
    end

    if emails_actualizados.any?
      puts "\nResumen de correos actualizados:"
      emails_actualizados.each { |email| puts " - #{email}" }
    else
      puts "\nNo se actualizó ningún correo."
    end

    puts "[#{Time.now}] Finalizó la ejecución del script."
  end
end
