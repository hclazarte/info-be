class Correo < ApplicationRecord
  enum tipo: { sugerencia: 0, consulta: 1, reclamo: 2, otro: 3 }, _prefix: :tipo
  enum estado: { pendiente: 0, enviado: 1, fallido: 2 }, _prefix: :estado

  validates :remitente, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :asunto, presence: true
  validates :tipo, presence: true
  validates :cuerpo, presence: true
end