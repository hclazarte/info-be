# app/models/correo_usuario.rb
class CorreoUsuario < ApplicationRecord
  self.table_name = 'correos_usuarios'

  belongs_to :comercio, optional: true
  enum estado: { pendiente: 0, enviado: 1, fallido: 2 }, _prefix: :estado

  validates :remitente, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :destinatario, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :asunto, presence: true
  validates :cuerpo, presence: true
  validates :intentos, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
