namespace :vale do
  desc "Generar un PDF de prueba de vale"
  task generar_pdf: :environment do
    vale = Vale.last || Vale.create!(fecha_vencimiento: 10.days.from_now)
    pdf = ValePdf.new(vale)
    File.open("tmp/vale_test.pdf", "wb") { |f| f.write pdf.generar }
    puts "PDF generado: tmp/vale_test.pdf"
  end
end
