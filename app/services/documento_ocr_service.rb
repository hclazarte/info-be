class DocumentoOcrService
  def initialize(archivo)
    @archivo = archivo
  end

  def extraer_texto
    imagen_path = convertir_a_imagen_si_pdf(@archivo)
    RTesseract.new(imagen_path).to_s
  end

  private

  def convertir_a_imagen_si_pdf(archivo)
    return archivo.path if archivo.content_type.start_with?('image/')

    # Convertir primera página del PDF a PNG
    imagen_temp = Tempfile.new(['ocr_page', '.png'])
    MiniMagick::Tool::Convert.new do |convert|
      convert.density(300)
      convert << "#{archivo.path}[0]"
      convert << imagen_temp.path
    end
    imagen_temp.path
  end
end
