class WhatsappMensaje < ApplicationRecord
  belongs_to :whatsapp_chat

  enum remitente: { usuario: 0, comercio: 1, plataforma: 2 }, _prefix: :rem
  enum destinatario: { usuario: 0, comercio: 1 }, _prefix: :des

  validates :cuerpo, presence: true
  validates :remitente, presence: true
  validates :destinatario, presence: true
end
