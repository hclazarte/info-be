class SolicitudesController < ApplicationController
  include TokenAutenticable
  before_action :autorizar_por_token, only: [:update]
  wrap_parameters false

  def create
    email       = params[:email]
    comercio_id = params[:comercio_id]

    return render json: { error: 'Email es obligatorio' },
                  status: :unprocessable_entity unless email.present?

    comercio = Comercio.find_by(id: comercio_id)
    return render json: { error: 'Comercio no encontrado' },
                  status: :not_found unless comercio

    result = actualiza_informacion(email, comercio)
    solicitud = result[:solicitud]
    mensaje   = result[:mensaje]
    status    = result[:status]

    EnviarTokenJob.perform_async(solicitud.id)

    render json: {
      message: mensaje,
      token:   solicitud.otp_token
    }, status: status

  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages },
          status: :unprocessable_entity
  end

  def buscar_por_token
    solicitud = Solicitud.includes(:comercio)
                         .find_by(otp_token: params[:token])

    if solicitud&.otp_expires_at && solicitud.otp_expires_at.future?
      render json: {
        solicitud: solicitud.as_json(only: %i[id email nombre estado ci_ok nit_ok fecha_fin_servicio]),
        comercio: solicitud.comercio&.as_json(only: %i[
                                                id
                                                latitud
                                                longitud
                                                zona_nombre
                                                calle_numero
                                                planta
                                                numero_local
                                                telefono1
                                                telefono2
                                                telefono_whatsapp
                                                horario
                                                empresa
                                                email
                                                pagina_web
                                                servicios
                                                contacto
                                                palabras_clave
                                                bloqueado
                                                activo
                                                nit
                                                ciudad_id
                                                zona_id
                                                documentos_validados
                                                autorizado
                                              ]).merge(seprec: solicitud.comercio.seprec?)
      }
    else
      render json: { error: 'Token inválido o expirado' }, status: :not_found
    end
  end

  def update
    if @solicitud.update(solicitud_params)
      render json: { message: 'Solicitud actualizada correctamente' }
    else
      render json: { errors: @solicitud.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def preparar_escenario
    return head :forbidden if Rails.env.production?

    alias_param = params[:alias].to_s
    casos = YAML.load_file(Rails.root.join('config', 'test_data.yml'))['casos_solicitudes']
    caso = casos[alias_param]
    return render json: { error: 'Caso no encontrado' }, status: :not_found unless caso

    email = caso['email']
    comercio_input = caso['comercio']
    return render json: { error: 'Datos incompletos' }, status: :unprocessable_entity unless email && comercio_input
    
    solicitud = caso['solicitud']
    comprobante = if caso.key?('comprobante') 
                    !!caso['comprobante']     
                  else
                    false
                  end
    delete_comercio = if caso.key?('delete_comercio') 
                        !!caso['delete_comercio']     
                      else
                        false
                      end

    comercio_attrs = TestDataGenerator.apply_testdata(comercio_input).with_indifferent_access

    Solicitud.where(comercio_id: comercio_attrs[:id]).delete_all

    if delete_comercio
      Comercio.where(id: comercio_attrs[:id]).delete_all
      comercio = Comercio.create!(comercio_attrs)
    else
      comercio = Comercio.find_or_initialize_by(id: comercio_attrs['id'])
      comercio.assign_attributes(comercio_attrs)
      comercio.save!
    end

    result = actualiza_informacion(email, comercio)
    solicitud = result[:solicitud]

    if caso['solicitud']
      solicitud_attrs = TestDataGenerator.apply_testdata(caso['solicitud']).with_indifferent_access
      solicitud.update!(solicitud_attrs)
    end

    payload = {
      comercio_id: comercio.id,
      token: solicitud.otp_token
    }

    if comprobante
      path = ComprobanteTest.generar
      pdf_base64 = Base64.encode64(File.read(path))
      payload[:comprobante_pdf] = {
        filename: 'comprobante.pdf',
        content_base64: pdf_base64,
        mime_type: 'application/pdf'
      }
    end

    render json: payload
  end

  private

  def solicitud_params
    params.require(:solicitud).permit(:nombre, :ci_ok, :nit_ok, :estado)
  end

  def actualiza_informacion(email, comercio)
    ActiveRecord::Base.transaction do
      solicitud = nil
      mensaje   = ''
      status    = :ok

      if comercio.email == email
        solicitud = Solicitud.where(comercio_id: comercio.id, email: email)
                            .where.not(estado: :rechazada)
                            .order(created_at: :desc)
                            .first_or_initialize

        solicitud.assign_attributes(
          otp_token:      SecureRandom.hex(10),
          otp_expires_at: 24.hours.from_now,
          estado:         :documentos_validados,
        )
        solicitud.save!

        comercio.update!(
          email_verificado:     email
        )

        mensaje = 'Solicitud procesada sin validación de documentos'
      else
        solicitud = Solicitud.where(comercio_id: comercio.id, email: email)
                            .where.not(estado: :rechazada)
                            .order(created_at: :desc)
                            .first

        if solicitud
          solicitud.update!(
            otp_token:      SecureRandom.hex(10),
            otp_expires_at: 24.hours.from_now
          )
          mensaje = 'Solicitud existente actualizada'
        else
          solicitud = Solicitud.create!(
            email:          email,
            comercio_id:    comercio.id,
            otp_token:      SecureRandom.hex(10),
            otp_expires_at: 24.hours.from_now,
            estado:         :pendiente_verificacion
          )
          mensaje = 'Solicitud creada exitosamente'
          status  = :created
        end
      end

      { solicitud:, mensaje:, status: }
    end
  end
end
