class ComerciosController < ApplicationController
  include RecaptchaVerifiable
  include TokenAutenticable

  before_action :verify_recaptcha, only: :crear_no_seprec

  STOP_LIST = %w[
    A B C D E F G H I J K L M N Ñ O P Q R S T U V W X Y Z Á É Í Ó Ú
    SR SRA SRES STA ACÁ AHÍ AJENA AJENAS AJENO AJENOS AL ALGO ALGUNA ALGUNAS
    ALGUNO ALGUNOS ALGÚN ALLÁ ALLÍ AQUEL AQUELLA AQUELLAS AQUELLO AQUELLOS
    AQUÍ CADA CIERTA CIERTAS CIERTO CIERTOS COMO CON CONMIGO CONSIGO CONTIGO
    CUALQUIER CUALQUIERA CUALQUIERAS CUAN CUANTA CUANTAS CUANTO CUANTOS CUÁN
    CUÁNTA CUÁNTAS CUÁNTO CUÁNTOS CÓMO DE DEJAR DEL DEMASIADA DEMASIADAS
    DEMASIADO DEMASIADOS DEMÁS EL ELLA ELLAS ELLOS ESA ESAS ESE ESOS ESTA
    ESTAR ESTAS ESTE ESTOS HACER HASTA JAMÁS JUNTO JUNTOS LA LAS LO LOS MAS
    ME MENOS MIENTRAS MISMA MISMAS MISMO MISMOS MUCHA MUCHAS MUCHO MUCHOS
    MUCHÍSIMA MUCHÍSIMAS MUCHÍSIMO MUCHÍSIMOS MUY MÁS MÍA MÍO NADA NI NINGUNA
    NINGUNAS NINGUNO NINGUNOS NO NOS NOSOTRAS NOSOTROS NUESTRA NUESTRAS
    NUESTRO NUESTROS NUNCA OS OTRA OTRAS OTRO OTROS PARA PARECER POCA POCAS
    POCO POCOS POR PORQUE QUE QUERER QUIEN QUIENES QUIENESQUIERA QUIENQUIERA
    QUIÉN QUÉ SER SI SIEMPRE SUYA SUYAS SUYO SUYOS SÍ SÍN TAL TALES TAN
    TANTA TANTAS TANTO TANTOS TE TENER TI TODA TODAS TODO TODOS TOMAR TUYA
    TUYO TÚ UN UNA UNAS UNOS USTED USTEDES VARIAS VARIOS VOSOTRAS VOSOTROS
    VUESTRA VUESTRAS VUESTRO VUESTROS Y YO ÉL
    AND OR NOT NEAR WITHIN ACCUMULATE MINUS SCORE ABOUT EQUIV NULL TRUE FALSE
  ].map(&:downcase).freeze

  # GET /comercios
  def lista
    page     = params[:page].to_i.positive?     ? params[:page].to_i     : 1
    per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 10
    offset   = (page - 1) * per_page

    base_scope = ComercioFilterService
                  .new(ciudad_id: params[:ciudad_id],
                        zona_id:   params[:zona_id],
                        text:      params[:text])
                  .call

    total_count = base_scope.count

    resultados = base_scope
                  .select(:id, :latitud, :longitud, :zona_nombre, :calle_numero,
                          :empresa, :servicios, :telefono1, :telefono2,
                          :whatsapp_verificado, :autorizado, :email_verificado)
                  .offset(offset)
                  .limit(per_page)
                  .map do |comercio|
                    comercio.as_json(only: [:id, :latitud, :longitud, :zona_nombre,
                                            :calle_numero, :empresa, :servicios,
                                            :telefono1, :telefono2, :whatsapp_verificado,
                                            :autorizado]).merge(
                      email_verificado: comercio.email_verificado.present?
                    )
                  end

    render json: {
      page: page,
      per_page: per_page,
      count: total_count,
      results: resultados
    }, status: :ok
  end

  def update
    was_not_authorized = @comercio.autorizado == 0
  
    if @comercio.update(comercio_params)
      if @comercio.autorizado == 1 && was_not_authorized
        solicitud = Solicitud.where(comercio_id: @comercio.id, email: @comercio.email_verificado).order(created_at: :desc).first
        unless solicitud
          render json: { errors: ['No se encontró una solicitud válida para habilitar el comercio.'] }, status: :unprocessable_entity and return
        end
  
        solicitud.estado = :comercio_habilitado
        solicitud.save
      end
  
      render json: { message: 'Comercio actualizado correctamente' }
    else
      render json: { errors: @comercio.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def por_email
    email = params[:email].to_s.strip.downcase
  
    if email.blank?
      return render json: { error: 'Debe proporcionar un correo electrónico' }, status: :bad_request
    end
  
    verificados = Comercio.where(email_verificado: email)
    no_verificados = Comercio.where(email: email, email_verificado: nil)
  
    comercios = verificados.or(no_verificados)
  
    render json: comercios.as_json(only: [:id, :empresa, :calle_numero, :ciudad_id, :nit])
  end

  def crear_no_seprec
    empresa = params[:empresa].to_s.strip
    email = params[:email].to_s.strip.downcase
    nit = params[:nit].to_s.strip.presence
    calle_numero = params[:calle_numero].to_s.strip
    ciudad_id = params[:ciudad_id]
  
    if empresa.blank? || email.blank? || calle_numero.blank? || ciudad_id.blank?
      return render json: { error: 'Empresa, correo electrónico, calle y ciudad son obligatorios' }, status: :bad_request
    end
  
    if Comercio.where('LOWER(empresa) = ?', empresa.downcase).exists?
      return render json: { error: 'Ya existe un comercio con ese nombre' }, status: :conflict
    end
  
    ActiveRecord::Base.transaction do
      comercio = Comercio.create!(
        empresa: empresa,
        nit: nit,
        email: email,
        email_verificado: nil,
        fecha_registro: Date.today,
        fecha_encuesta: Date.today,
        observacion: 'PLATAFORMA',
        calle_numero: calle_numero,
        ciudad_id: ciudad_id,
        documentos_validados: 1
      )
  
      # Reutilizamos lógica de creación de solicitud
      solicitud_existente = Solicitud.where(comercio_id: comercio.id, email: email).where.not(estado: 5).order(created_at: :desc).first
  
      if solicitud_existente
        solicitud_existente.update!(
          otp_token: SecureRandom.hex(10),
          otp_expires_at: 24.hours.from_now
        )
        EnviarTokenJob.perform_async(solicitud_existente.id)
        return render json: { message: 'Solicitud existente actualizada', token: solicitud_existente.otp_token }, status: :ok
      end
  
      solicitud = Solicitud.create!(
        comercio: comercio,
        email: email,
        otp_token: SecureRandom.hex(10),
        otp_expires_at: 24.hours.from_now,
        estado: :documentos_validados,
        nit_ok: 1,
        ci_ok: 1,
      )
  
      EnviarTokenJob.perform_async(solicitud.id)
      render json: { message: 'Solicitud creada exitosamente', token: solicitud.otp_token }, status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
  end   

  private

  def comercio_params
    params.require(:comercio).permit(
      :telefono1, :telefono2, :telefono_whatsapp, :email, :pagina_web, :servicios,
      :contacto, :palabras_clave, :bloqueado, :activo, :horario, :latitud, :longitud,
      :zona_nombre, :calle_numero, :planta, :numero_local, :nit, :ciudad_id, :zona_id,
      :autorizado, :documentos_validados, :autorizado
    )
  end

end
