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

  def enviar
    CorreoMailer.enviar_personalizado(
      from: enviar_params[:from],
      to:   enviar_params[:to],
      asunto: enviar_params[:asunto],
      mensaje: enviar_params[:mensaje]
    ).deliver_later

    render json: { message: 'Correo enviado correctamente' }, status: :ok
  rescue StandardError => e
    Rails.logger.error("[CorreoMailer#enviar_personalizado] #{e.class}: #{e.message}")
    render json: { error: 'No se pudo enviar el correo' }, status: :unprocessable_entity
  end

  private

  def correo_params
    params.require(:correo).permit(:nombre, :remitente, :asunto, :tipo, :cuerpo)
          .merge(estado: :pendiente, intentos: 0, fecha: Time.current)
  end

  def enviar_params
    # payload esperado: { correo: { from:, to:, asunto:, mensaje: } }
    params.require(:correo).permit(:from, :to, :asunto, :mensaje)
  end

  def validate_params
    return if params[:correo].present?

    render json: { error: "Se requiere el objeto 'correo'" }, status: :bad_request
  end

  def validate_enviar_params
    unless params[:correo].is_a?(ActionController::Parameters)
      render json: { error: "Se requiere el objeto 'correo'" }, status: :bad_request and return
    end

    required = %i[from to asunto mensaje]
    faltantes = required.select { |k| enviar_params[k].blank? }
    return if faltantes.empty?

    render json: { error: "Parámetros faltantes: #{faltantes.join(', ')}" }, status: :unprocessable_entity
  end
end
