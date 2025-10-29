# app/controllers/api/keywords_controller.rb
# frozen_string_literal: true

class KeywordsController < ApplicationController
  # No auth: la interfaz está protegida por OTP_TOKEN en el front.
  # Forzamos JSON en respuesta.

  def sugerir
    payload = sugerir_params
    result  = SugerirKeywordsService.call(payload, model: :"gpt-4.1-mini")

    render json: {
      keywords: result[:keywords],
      ofertas:  result[:ofertas]
    }, status: :ok

  rescue SugerirKeywordsService::InvalidResponse => e
    render json: { message: e.message }, status: :service_unavailable
  rescue SugerirKeywordsService::ProviderError => e
    render json: { message: e.message, retry_after: 10 }, status: :service_unavailable
  rescue ActionController::ParameterMissing => e
    render json: { errors: [{ field: e.param, message: "obligatorio" }] }, status: :unprocessable_entity
  end

  private

  # Permitimos los campos conocidos y dejamos pasar extras sin romper (por compatibilidad)
  def sugerir_params
    params.permit(
      :negocio, :rubro,
      tipo: [], top_servicios: [], promocionar_ahora: [], marcas: [],
      ubicacion: [], diferenciadores: [], publico_objetivo: []
    ).to_h
  end
end
