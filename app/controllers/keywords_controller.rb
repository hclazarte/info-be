# app/controllers/api/keywords_controller.rb
# frozen_string_literal: true

class KeywordsController < ApplicationController

  def sugerir
    payload = sugerir_params

    # Guardar el JSON exacto del payload en el comercio (opcional)
    if params[:comercio_id].present?
      if (comercio = Comercio.find_by(id: params[:comercio_id]))
        comercio.update!(wizard_payload: payload.to_json)
      end
    end

    result  = SugerirKeywordsService.call(payload, model: :"gpt-4.1-mini")

    render json: {
      keywords: result[:keywords],
      ofertas:  result[:ofertas]
    }, status: :ok

  rescue SugerirKeywordsService::InvalidResponse => e
    render json: { message: e.message }, status: :service_unavailable
  rescue SugerirKeywordsService::ProviderError => e
    render json: { message: e.message, retry_after: 10 }, status: :service_unavailable
  rescue ActiveRecord::RecordInvalid => e
    render json: { message: "No se pudo guardar wizard_payload: #{e.message}" }, status: :unprocessable_entity
  end

  private

  # Ahora SOLO permitimos empresa/servicios + el resto. Se quitan :negocio y :rubro.
  def sugerir_params
    params.permit(
      :empresa,          # String (antes "negocio")
      :servicios,        # String (antes "rubro"; corresponde al campo visible SERVICIOS)
      :comercio_id,      # opcional, para guardar wizard_payload
      tipo: [],
      top_servicios: [],
      promocionar_ahora: [],
      marcas: [],
      ubicacion: [],
      diferenciadores: [],
      publico_objetivo: []
    ).to_h.except("comercio_id") # al servicio NO le pasamos el id
  end
end
