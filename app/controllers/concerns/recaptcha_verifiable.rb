module RecaptchaVerifiable
  extend ActiveSupport::Concern

  included do
    before_action :verify_recaptcha, only: [:lista]  # aplicar solo a la acción deseada
  end

  private

  def verify_recaptcha
    return if ip_whitelisted?

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

  def ip_whitelisted?
    trusted_ips = [
      '127.0.0.1', '::1', 
      '190.181.25.130', 
      '']

    # Acepta cualquier IP del rango 192.168.0.x
    return true if request.remote_ip.start_with?('192.168.0.')
  
    trusted_ips.include?(request.remote_ip)
  end
end
