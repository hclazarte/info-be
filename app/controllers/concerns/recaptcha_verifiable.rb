# app/controllers/concerns/recaptcha_verifiable.rb
require "faraday"

module RecaptchaVerifiable
  extend ActiveSupport::Concern

  private

  def verify_recaptcha
    return true unless recaptcha_enabled?
    return true if ip_whitelisted?

    token = params[:recaptcha_token]
    return render json: { error: 'Falta el token de reCAPTCHA' }, status: :bad_request unless token

    response = Faraday.post('https://www.google.com/recaptcha/api/siteverify', {
      secret: ENV['RECAPTCHA_SECRET_KEY'],
      response: token
    })

    result = JSON.parse(response.body)

    return true if result['success'] && result['score'].to_f > 0.5

    render json: { error: 'Verificación de reCAPTCHA fallida' }, status: :forbidden

  rescue Faraday::Error => e
    Rails.logger.error("reCAPTCHA error: #{e.class}: #{e.message}")
    render json: { error: 'Servicio reCAPTCHA no disponible' }, status: :service_unavailable
  end

  def ip_whitelisted?
    trusted_ips = ['127.0.0.1','::1','190.181.25.130','172.18.0.1','']
    return true if client_ip.start_with?('192.168.0.')
    trusted_ips.include?(client_ip)
  end

  def recaptcha_enabled?
    ENV['INFOMOVIL_RECAPTCHA_ENABLE'].to_s.downcase == 'true'
  end
end
