require 'prawn'
require 'stringio'

class ValePdf
  def initialize(vale)
    @vale = vale
  end

  def generar
    pdf_temp = Tempfile.new(['vale_tmp', '.pdf'])
    
    # Paso 1: crear capa con datos del vale
    Prawn::Document.generate(pdf_temp.path, page_size: 'A5', margin: 0) do |pdf|
      pdf.font 'Helvetica'
      pdf.font_size 10

      # Insertar texto en coordenadas aproximadas
      pdf.draw_text @vale.codigo.to_s, at: [200, 337]
      if @vale.comercio
        pdf.draw_text @vale.comercio.empresa.to_s, at: [215, 324]
      else
        pdf.draw_text "Válido para cualquier comercio", at: [215, 324]
      end
      pdf.draw_text @vale.fecha_vencimiento.strftime("%Y-%m-%d"),     at: [228, 311]
    end

    # Paso 2: fusionar con plantilla
    plantilla = CombinePDF.load(Rails.root.join('app/assets/pdf/Vale.pdf'))
    datos = CombinePDF.load(pdf_temp.path)
    
    plantilla.pages[0] << datos.pages[0]

    plantilla.to_pdf.force_encoding("ASCII-8BIT")
  ensure
    pdf_temp.close
    pdf_temp.unlink
  end
end
