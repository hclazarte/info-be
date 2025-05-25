class SolicitudesController < ApplicationController
  include TokenAutenticable
  before_action :autorizar_por_token, only: [:update]
  wrap_parameters false

  def create
    email       = params[:email]
    comercio_id = params[:comercio_id]
  
    return render json: { error: 'Email es obligatorio' },
                  status: :unprocessable_entity unless email.present?
  
    comercio = Comercio.find(comercio_id)
    return render json: { error: 'Comercio no encontrado' },
                  status: :not_found unless comercio
  
    ActiveRecord::Base.transaction do
      if comercio.email == email
        solicitud = Solicitud.where(comercio_id: comercio_id, email: email)
                             .where.not(estado: :rechazada)
                             .order(created_at: :desc)
                             .first_or_initialize
  
        solicitud.assign_attributes(
          otp_token:      SecureRandom.hex(10),
          otp_expires_at: 30.minutes.from_now,
          estado:         :documentos_validados                         # enum = 1
        )
  
        comercio.update!(
          email_verificado:     email,
          documentos_validados: true
        )
  
        solicitud.save!
        EnviarTokenJob.perform_async(solicitud.id)
  
        return render json: { message: 'Solicitud procesada sin validación de documentos',
                              token:   solicitud.otp_token },
                      status: :ok
      end
  
      # ─────────────────────────────────────────────
      # 3. Flujo original (no coincide el email)
      # ─────────────────────────────────────────────
      solicitud_existente = Solicitud.where(comercio_id: comercio_id, email: email)
                                     .where.not(estado: 5)
                                     .order(created_at: :desc)
                                     .first
  
      if solicitud_existente
        solicitud_existente.update!(
          otp_token:      SecureRandom.hex(10),
          otp_expires_at: 30.minutes.from_now
        )
        EnviarTokenJob.perform_async(solicitud_existente.id)
        return render json: { message: 'Solicitud existente actualizada',
                              token:   solicitud_existente.otp_token },
                      status: :ok
      end
  
      # Si no existe una solicitud válida, se crea una nueva
      solicitud = Solicitud.create!(
        email:          email,
        comercio_id:    comercio_id,
        otp_token:      SecureRandom.hex(10),
        otp_expires_at: 30.minutes.from_now,
        estado:         :pendiente_verificacion                         # enum = 0
      )
  
      EnviarTokenJob.perform_async(solicitud.id)
      render json: { message: 'Solicitud creada exitosamente',
                     token:   solicitud.otp_token },
             status: :created
    end
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

  private

  def solicitud_params
    params.require(:solicitud).permit(:nombre, :ci_ok, :nit_ok, :estado)
  end
end
