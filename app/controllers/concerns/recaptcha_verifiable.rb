require 'faraday'

module RecaptchaVerifiable
  extend ActiveSupport::Concern

  included do
    # before_action :verify_recaptcha, if: -> { Rails.env.production? && request.post? }
  end

  private

  def verify_recaptcha
    token = params[:recaptcha_token]
    return render json: { error: "Falta el token de reCAPTCHA" }, status: :bad_request unless token

    response = Faraday.post("https://www.google.com/recaptcha/api/siteverify", {
      secret: ENV['RECAPTCHA_SECRET_KEY'],
      response: token
    })

    result = JSON.parse(response.body)
    
    unless result["success"] && result["score"].to_f > 0.5
      render json: { error: "Verificación de reCAPTCHA fallida" }, status: :forbidden
    end
  end
end
