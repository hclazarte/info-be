module RecaptchaVerifiable
  extend ActiveSupport::Concern

  included do
    # Comentado el before_action para desactivar recaptcha por completo
    # before_action :verify_recaptcha, only: [:lista]
  end

  private

  def client_ip
    header = request.headers['X-Forwarded-For']
    header.present? ? header.split(',').first.strip : request.remote_ip
  end

  def verify_recaptcha
    return unless Rails.env.production?
    return if ip_whitelisted?

    token = params[:recaptcha_token]
    return render json: { error: 'Falta el token de reCAPTCHA' }, status: :bad_request unless token

    response = Faraday.post('https://www.google.com/recaptcha/api/siteverify', {
                              secret: ENV['RECAPTCHA_SECRET_KEY'],
                              response: token
                            })

    result = JSON.parse(response.body)

    return if result['success'] && result['score'].to_f > 0.5

    render json: { error: 'Verificación de reCAPTCHA fallida' }, status: :forbidden
  end

  def ip_whitelisted?
    trusted_ips = [
      '127.0.0.1', '::1',
      '190.181.25.130',
      '172.18.0.1',
      ''
    ]

    return true if client_ip.start_with?('192.168.0.')

    trusted_ips.include?(client_ip)
  end
end
