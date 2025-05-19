module UnsubHelper
  def unsubscribe_url(email)
    token = UnsubToken.generate(email)
    "#{Rails.configuration.base_url}/app/cancelar-suscripcion?token=#{token}"
  end
end
