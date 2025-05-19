class UnsubToken
  SECRET = Rails.application.secret_key_base
  ALG    = 'HS256'

  def self.generate(email, ttl = 24.hours)
    payload = { email: email, exp: ttl.from_now.to_i, purpose: 'unsubscribe' }
    JWT.encode(payload, SECRET, ALG)
  end

  def self.decode(token)
    JWT.decode(token, SECRET, true, algorithm: ALG).first
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
