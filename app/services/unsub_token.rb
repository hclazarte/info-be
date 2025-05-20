class UnsubToken
  SECRET = Rails.application.secret_key_base
  ALG    = 'HS256'

  # Generar token sin el padding “=”
  def self.generate(email, ttl = 24.hours)
    payload = { email:, exp: ttl.from_now.to_i, purpose: 'unsubscribe' }
    JWT.encode(payload, SECRET, ALG).tr('=', '')  # ← quita los “=”
  end

  # Decodificar añadiendo el padding que falte
  def self.decode(token)
    padded = token + '=' * ((4 - token.length % 4) % 4)
    JWT.decode(padded, SECRET, true, algorithm: ALG).first
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
