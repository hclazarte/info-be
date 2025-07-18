class CorreosController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :validate_params, only: [:create]

  def create
    correo = Correo.new(correo_params)

    if correo.save
      BuzonMailer.enviar_mensaje_portal(correo).deliver_later # <-- Asegura que es deliver_later
      ConfirmacionMailer.confirmacion_usuario(correo).deliver_later
      render json: { message: 'Mensaje recibido correctamente', id: correo.id }, status: :created
    else
      render json: { error: correo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def correo_params
    params.require(:correo).permit(:nombre, :remitente, :asunto, :tipo, :cuerpo)
          .merge(estado: :pendiente, intentos: 0, fecha: Time.current)
  end

  def validate_params
    return if params[:correo].present?

    render json: { error: "Se requiere el objeto 'correo'" }, status: :bad_request
  end
end
