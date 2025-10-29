# app/controllers/api/keywords_controller.rb
# frozen_string_literal: true

class KeywordsController < ApplicationController
  include RecaptchaVerifiable

  before_action :verify_recaptcha, only: :suggest

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

  # Permitimos campos del payload y el token de reCAPTCHA
  def sugerir_params
    params.permit(
      :negocio, :rubro, :recaptcha_token,
      tipo: [], top_servicios: [], promocionar_ahora: [], marcas: [],
      ubicacion: [], diferenciadores: [], publico_objetivo: []
    ).to_h.except("recaptcha_token") # el token NO se pasa al servicio
  end

  # Si tu concern usa client_ip, garantizamos su existencia aquí
  def client_ip
    request.remote_ip.to_s
  end
end
