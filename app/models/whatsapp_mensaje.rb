class WhatsappMensaje < ApplicationRecord
  belongs_to :whatsapp_chat

  enum remitente: { usuario: 0, comercio: 1, plataforma: 2 }
  enum destinatario: { usuario: 0, comercio: 1 }

  validates :cuerpo, presence: true
  validates :remitente, presence: true
end
