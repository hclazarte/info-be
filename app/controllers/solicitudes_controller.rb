class SolicitudesController < ApplicationController
  # Bypass del CSRF token en desarrollo o para llamadas tipo API
  protect_from_forgery with: :null_session
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
end