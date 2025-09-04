# app/services/comprobante_test.rb
require 'prawn'

class ComprobanteTest
  DESTINO = Rails.root.join('tmp', 'comprobante_test.pdf')
  BANCO = 'UNION'
  CUENTA = '10000022978528'

  def self.generar
    fecha = Date.today.strftime('%d/%m/%Y')

    Prawn::Document.generate(DESTINO) do |pdf|
      pdf.font 'Helvetica'
      pdf.font_size 14

      pdf.move_down 100
      pdf.text fecha, align: :center
      pdf.move_down 20
      pdf.text BANCO, align: :center
      pdf.move_down 20
      pdf.text CUENTA, align: :center
    end

    DESTINO
  end
end
