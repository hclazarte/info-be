# app/controllers/concerns/token_autenticable.rb
module TokenAutenticable
  extend ActiveSupport::Concern

  included do
    before_action :autorizar_por_token, only: [] # Agrega las acciones en los controladores
  end

  private

  def extraer_token
    params[:token] || request.headers['Authorization']&.split('Bearer ')&.last
  end

  def autorizar_por_token
    token = extraer_token
    @solicitud = Solicitud.find_by(otp_token: token)

    unless @solicitud
      render json: { error: 'Token inválido o expirado' }, status: :unauthorized
    end
  end

  def autorizar_comercio_por_token
    token = extraer_token
    @comercio = Comercio.find(params[:id])
    solicitud = Solicitud.find_by(otp_token: token)

    unless solicitud && solicitud.comercio_id == @comercio.id
      render json: { error: 'No autorizado para modificar este comercio' }, status: :unauthorized
    end
  end
end
