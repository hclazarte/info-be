# app/controllers/documentos_controller.rb
class DocumentosController < ApplicationController
  def validar_nit
    archivo = params[:archivo]
    solicitud_id = params[:solicitud_id]

    return render json: { error: 'Faltan parámetros' }, status: :bad_request unless archivo && solicitud_id

    solicitud = Solicitud.find_by(id: solicitud_id)
    return render json: { error: 'Solicitud no encontrada' }, status: :not_found unless solicitud

    solicitud.update(nit_imagen: archivo.read)

    comercio = solicitud.comercio
    return render json: { error: 'Comercio no asociado a la solicitud' }, status: :not_found unless comercio

    texto = DocumentoOcrService.new(archivo).extraer_texto

    # Extraer NIT, razón social (contribuyente)
    nit_extraido = texto[/\b(\d{6,})\b/, 1]
    razon_social = texto[/Contribuyente:\s*(.+?)\n/i, 1]&.strip
    representante = extraer_representante_legal(texto)

    if Rails.env.development? || ENV['RAILS_LOG_LEVEL'] == 'debug'
      Rails.logger.info "OCR NIT extraído:\n#{texto}"
      Rails.logger.info "NIT extraído: #{nit_extraido}"
      Rails.logger.info "Razón social: #{razon_social}"
      Rails.logger.info "Representante legal: #{representante}"
      Rails.logger.info "Comercio: ID=#{comercio.id}, Empresa=#{comercio.empresa}"
    end

    if comercio.nit.to_s != nit_extraido
      return render json: { validado: false, mensaje: 'Lo siento, la información no pudo ser validada' }
    end

    razon_social_normalizada = normalizar_texto(razon_social)
    empresa_normalizada = normalizar_texto(comercio.empresa)

    if razon_social && razon_social_normalizada != empresa_normalizada
      return render json: { validado: false, mensaje: 'Lo siento, la información no pudo ser validada' }
    end

    ActiveRecord::Base.transaction do
      solicitud.update!(
        nit_ok: true
      )
      comercio.update!(contacto: representante)

      unless comercio.documentos_validados
        comercio.update!(
          documentos_validados: solicitud.nit_ok && solicitud.ci_ok,
          email: solicitud.email
        )
      end
    end

    render json: { validado: true }
  rescue StandardError => e
    Rails.logger.error "ERROR validar_nit: #{e.full_message}" if Rails.env.development?
    render json: { validado: false, mensaje: 'Lo siento, la información no pudo ser validada' },
           status: :unprocessable_entity
  end

  def validar_ci
    archivo = params[:archivo]
    solicitud_id = params[:solicitud_id]

    return render json: { error: 'Faltan parámetros' }, status: :bad_request unless archivo && solicitud_id

    solicitud = Solicitud.find_by(id: solicitud_id)
    return render json: { error: 'Solicitud no encontrada' }, status: :not_found unless solicitud

    solicitud.update(ci_imagen: archivo.read)

    comercio = solicitud.comercio
    return render json: { error: 'Comercio no asociado a la solicitud' }, status: :not_found unless comercio

    texto = DocumentoOcrService.new(archivo).extraer_texto

    if Rails.env.development?
      Rails.logger.info "OCR CI extraído:\n#{texto}"
      Rails.logger.info "Contacto actual en comercio: #{comercio.contacto}"
    end

    if nombre_coincide?(comercio.contacto, texto)
      solicitud.update!(ci_ok: true, estado: :documentos_validados)

      comercio.update!(
        documentos_validados: solicitud.nit_ok && solicitud.ci_ok,
        email: solicitud.email
      )

      render json: { validado: true }
    else
      render json: { validado: false, mensaje: 'Lo siento, la información no pudo ser validada' }
    end

  rescue StandardError => e
    Rails.logger.error "ERROR validar_ci: #{e.full_message}" if Rails.env.development?
    render json: { validado: false, mensaje: 'Lo siento, la información no pudo ser validada' },
           status: :unprocessable_entity
  end

  def validar_comprobante
    archivo = params[:archivo]
    solicitud_id = params[:solicitud_id]

    return render json: { error: 'Faltan parámetros' }, status: :bad_request unless archivo && solicitud_id

    solicitud = Solicitud.find_by(id: solicitud_id)
    return render json: { error: 'Solicitud no encontrada' }, status: :not_found unless solicitud

    solicitud.update(
      comprobante_imagen: archivo.read,
      fecha_fin_servicio: 1.year.from_now
    )

    comercio = solicitud.comercio
    return render json: { error: 'Comercio no asociado a la solicitud' }, status: :not_found unless comercio

    texto = DocumentoOcrService.new(archivo).extraer_texto
    if Rails.env.development?
      Rails.logger.info "OCR Comprobante extraído:\n#{texto}"
      Rails.logger.info "Cuenta encontrada? #{texto.include?('10000022978528')}"
    end

    cuenta_ok = texto.include?('10000022978528')
    banco_ok  = texto.upcase.include?('UNION')
    fecha_ok  = fecha_valida?(texto)

    if cuenta_ok
      solicitud.update!(estado: :pago_validado)
      render json: { validado: true }
    else
      render json: { validado: false, mensaje: 'Lo siento, la información no pudo ser validada' }
    end
  rescue StandardError => e
    Rails.logger.error "ERROR validar_comprobante: #{e.full_message}" if Rails.env.development?
    render json: { validado: false, mensaje: 'Lo siento, la información no pudo ser validada' },
           status: :unprocessable_entity
  end

  private

  def normalizar_texto(texto)
    I18n.transliterate(texto.to_s).downcase.gsub('.', '').gsub(',', '').strip
  end

  def extraer_representante_legal(texto)
    texto[/([A-ZÁÉÍÓÚÑ ]{5,})\s+C[IL]:?\s*\d+/i, 1]&.strip
  end

  def normalizar_texto(texto)
    I18n.transliterate(texto.to_s).downcase.gsub('.', '').gsub(',', '').strip
  end

  def nombre_coincide?(nombre, texto_ocr)
    return false if nombre.blank? || texto_ocr.blank?
  
    nombre_completo = "#{nombre} CEDULA IDENTIDAD IDENTIFICACION FOTOGRAFIA FIRMA"
    nombre_normalizado = normalizar_texto(nombre_completo).upcase
    texto_normalizado = normalizar_texto(texto_ocr).upcase
  
    palabras = nombre_normalizado.split
    return false if palabras.empty?
  
    coincidencias = palabras.count { |palabra| texto_normalizado.include?(palabra) }
  
    coincidencias >= (palabras.size * 0.75).ceil
  end

  def fecha_valida?(texto)
    return false if texto.blank?
  
    texto = texto.gsub(/[^\d\/\-]/, ' ') # limpieza rápida
    posibles_fechas = texto.scan(/(\d{2}[\/\-]\d{2}[\/\-]\d{4})/).flatten
  
    posibles_fechas.any? do |fecha_str|
      begin
        fecha = Date.strptime(fecha_str, '%d/%m/%Y') rescue Date.strptime(fecha_str, '%d-%m-%Y')
        (Date.today - fecha).to_i <= 2
      rescue ArgumentError
        false
      end
    end
  end  
end
