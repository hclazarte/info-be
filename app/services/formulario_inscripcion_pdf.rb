require 'prawn'
require 'combine_pdf'

class FormularioInscripcionPdf
  def initialize(comercio)
    @comercio = comercio
  end

  def generar
    pdf_temp = Tempfile.new(['formulario_tmp', '.pdf'])
    
    ciudad = Ciudad.find(@comercio.ciudad_id)
    nombre_ciudad = ciudad&.ciudad.to_s


    # Paso 1: crear capa con datos del comercio
    Prawn::Document.generate(pdf_temp.path, page_size: 'LETTER', margin: 0) do |pdf|
      pdf.font 'Helvetica'
      pdf.font_size 9

      # Insertar texto en coordenadas aproximadas
      pdf.draw_text @comercio.empresa.to_s, at: [155, 397]
      pdf.draw_text @comercio.email.to_s,   at: [155, 367]
      pdf.draw_text @comercio.nit.to_s,     at: [155, 337]  
      pdf.draw_text nombre_ciudad,          at: [155, 307]
    end

    # Paso 2: fusionar con plantilla
    plantilla = CombinePDF.load(Rails.root.join('app/assets/pdf/Inscripcion.pdf'))
    datos = CombinePDF.load(pdf_temp.path)
    resultado = CombinePDF.new

    plantilla.pages.each_with_index do |pagina, i|
      if i == 0
        resultado << (pagina << datos.pages[0]) # solo la primera página tiene overlay
      else
        resultado << pagina # las demás se copian tal como están
      end
    end    

    resultado.to_pdf
  ensure
    pdf_temp.close
    pdf_temp.unlink
  end
end
