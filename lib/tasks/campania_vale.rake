namespace :vale do
  desc "Generar un PDF de prueba de vale"
  task vale_test: :environment do
    vale = Vale.last || Vale.create!(fecha_vencimiento: 10.days.from_now)
    pdf = ValePdf.new(vale)
    File.open("tmp/vale_test.pdf", "wb") { |f| f.write pdf.generar }
    puts "PDF generado: tmp/vale_test.pdf"
  end

  desc "Ejecuta una campaña de vales sobre una sola solicitud"
  task ejecutar: :environment do
    solicitud = if ENV["ID"]
      Solicitud.find_by(id: ENV["ID"])
    else
     solicitud = Solicitud
      .joins(:comercio)
      .where("solicitudes.email IS NOT NULL")
      .where("solicitudes.comercio_id IS NOT NULL")
      .where("solicitudes.fecha_fin_servicio IS NULL OR solicitudes.fecha_fin_servicio < SYSDATE")
      .where("comercios.documentos_validados = 1")
      .order(Arel.sql("DBMS_RANDOM.VALUE"))
      .first
    end

    unless solicitud
      puts "No hay solicitudes válidas para ejecutar la campaña."
      exit
    end

    comercio = solicitud.comercio
    unless comercio
      puts "La solicitud seleccionada no tiene comercio asociado."
      exit
    end

    # Regenerar token
    solicitud.otp_token = SecureRandom.hex(10)
    solicitud.otp_expires_at = 24.hours.from_now
    solicitud.save!

    # Crear vale
    vale = Vale.create!(
      comercio: comercio,
      fecha_vencimiento: 10.days.from_now,
      motivo: "Campaña individual desde Rake"
    )

    # Generar PDF
    pdf = ValePdf.new(vale)
    pdf_io = StringIO.new(pdf.generar)
    pdf_io.rewind

    CampaniaValesMailer.promocion_vales(solicitud, vale, pdf_io).deliver_now

    puts "Vale #{vale.codigo} enviado a #{solicitud.email}"
  end
end
