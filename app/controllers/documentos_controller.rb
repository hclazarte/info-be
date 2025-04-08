# app/controllers/documentos_controller.rb
class DocumentosController < ApplicationController
  def validar_nit
    archivo = params[:archivo]
    solicitud_id = params[:solicitud_id]

    return render json: { error: "Faltan parámetros" }, status: :bad_request unless archivo && solicitud_id

    solicitud = Solicitud.find_by(id: solicitud_id)
    return render json: { error: "Solicitud no encontrada" }, status: :not_found unless solicitud

    solicitud.update(nit_imagen: archivo.read)

    comercio = solicitud.comercio
    return render json: { error: "Comercio no asociado a la solicitud" }, status: :not_found unless comercio

    texto = DocumentoOcrService.new(archivo).extraer_texto

    # Extraer NIT, razón social (contribuyente)
    nit_extraido = texto[/\b(\d{6,})\b/, 1]
    razon_social = texto[/Contribuyente:\s*(.+?)\n/i, 1]&.strip
    representante = extraer_representante_legal(texto)

    # puts "TEXTO EXTRAÍDO:\n#{texto}"
    # puts "NIT extraído: #{nit_extraido}"
    # puts "Razón social extraída: #{razon_social}"
    # puts "Representante legal: #{representante}"
    # puts "Empresa esperada: #{comercio.empresa}"

    if comercio.nit.to_s != nit_extraido
      return render json: { validado: false, mensaje: "Lo siento, la información no pudo ser validada" }
    end

    razon_social_normalizada = normalizar_texto(razon_social)
    empresa_normalizada = normalizar_texto(comercio.empresa)

    if razon_social && razon_social_normalizada != empresa_normalizada
      return render json: { validado: false, mensaje: "Lo siento, la información no pudo ser validada" }
    end

    ActiveRecord::Base.transaction do
      solicitud.update!(
        nit_ok: true
      )

      unless comercio.documentos_validados
        comercio.update!(
          contacto: representante,
          email: solicitud.email,
          documentos_validados: (solicitud.nit_ok && solicitud.ci_ok)
        )
      end      
    end

    render json: { validado: true }
  rescue => e
    render json: { validado: false, mensaje: "Lo siento, la información no pudo ser validada" }, status: :unprocessable_entity
  end

  def validar_ci
    archivo = params[:archivo]
    solicitud_id = params[:solicitud_id]

    return render json: { error: "Faltan parámetros" }, status: :bad_request unless archivo && solicitud_id

    solicitud = Solicitud.find_by(id: solicitud_id)
    return render json: { error: "Solicitud no encontrada" }, status: :not_found unless solicitud

    solicitud.update(ci_imagen: archivo.read)

    comercio = solicitud.comercio
    return render json: { error: "Comercio no asociado a la solicitud" }, status: :not_found unless comercio

    texto = DocumentoOcrService.new(archivo).extraer_texto

    nombre_extraido = texto[/([A-ZÁÉÍÓÚÑ ]{5,})\s+C[IL][:]?\s*\d+/i, 1]&.strip

    if normalizar_texto(nombre_extraido) == normalizar_texto(comercio.contacto)
      solicitud.update!(ci_ok: true, estado: :documentos_validados)

      comercio.update!(
          documentos_validados: (solicitud.nit_ok && solicitud.ci_ok)
        )

      render json: { validado: true }
    else
      render json: { validado: false, mensaje: "Lo siento, la información no pudo ser validada" }
    end

  rescue => e
    render json: { validado: false, mensaje: "Lo siento, la información no pudo ser validada" }, status: :unprocessable_entity
  end

  def validar_comprobante
    archivo = params[:archivo]
    solicitud_id = params[:solicitud_id]
  
    return render json: { error: "Faltan parámetros" }, status: :bad_request unless archivo && solicitud_id
  
    solicitud = Solicitud.find_by(id: solicitud_id)
    return render json: { error: "Solicitud no encontrada" }, status: :not_found unless solicitud
  
    solicitud.update(comprobante_imagen: archivo.read)
  
    comercio = solicitud.comercio
    return render json: { error: "Comercio no asociado a la solicitud" }, status: :not_found unless comercio
  
    texto = DocumentoOcrService.new(archivo).extraer_texto
    puts "TEXTO EXTRAÍDO:"
    puts texto
    puts "Cuenta encontrada? #{texto.include?('10000022978528')}"
    puts "Monto detectado: #{texto[/\\b\\d+[\\.,]?\\d*\\b/]}"
    
    cuenta_ok = texto.include?("10000022978528")
  
    if cuenta_ok
      solicitud.update!(estado: :pago_validado)
      render json: { validado: true }
    else
      render json: { validado: false, mensaje: "Lo siento, la información no pudo ser validada" }
    end
  rescue => e
    render json: { validado: false, mensaje: "Lo siento, la información no pudo ser validada" }, status: :unprocessable_entity
  end  
  
  private

  def normalizar_texto(texto)
    I18n.transliterate(texto.to_s).downcase.gsub('.', '').gsub(',', '').strip
  end

  private

  def extraer_representante_legal(texto)
    representante = texto[/([A-ZÁÉÍÓÚÑ ]{5,})\s+C[IL][:]?\s*\d+/i, 1]&.strip
  end
  
  def normalizar_texto(texto)
    I18n.transliterate(texto.to_s).downcase.gsub('.', '').gsub(',', '').strip
  end
end
