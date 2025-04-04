class SolicitudesController < ApplicationController
  wrap_parameters false
  
  def create
    email = params[:email]
    id_comercio = params[:id_comercio]

    unless email.present?
      return render json: { error: 'Email es obligatorio' }, status: :unprocessable_entity
    end

    otp_token = SecureRandom.hex(10)
    otp_expires_at = 30.minutes.from_now

    solicitud = Solicitud.new(
      email: email,
      comercio_id: id_comercio,
      otp_token: otp_token,
      otp_expires_at: otp_expires_at,
      estado: :pendiente_verificacion
    )

    if solicitud.save
      EnviarTokenJob.perform_async(solicitud.id)
      render json: { message: 'Solicitud creada exitosamente', token: otp_token }, status: :created
    else
      render json: { errors: solicitud.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def buscar_por_token
    solicitud = Solicitud.includes(:comercio).find_by(otp_token: params[:token])

    if solicitud
      render json: {
        solicitud: solicitud.as_json(only: [:id, :email, :nombre, :estado, :ci_ok, :nit_ok]),
        comercio: solicitud.comercio&.as_json(only: [
          :id,
          :latitud,
          :longitud,
          :zona_nombre,
          :calle_numero,
          :planta,
          :numero_local,
          :telefono1,
          :telefono2,
          :telefono3,
          :horario,
          :empresa,
          :email,
          :pagina_web,
          :servicios,
          :contacto,
          :palabras_clave,
          :bloqueado,
          :activo,
          :nit,
          :ciudad_id,
          :zona_id
        ])
      }
    else
      render json: { error: 'Token inválido o expirado' }, status: :not_found
    end
  end
end
