class WhatsappChat < ApplicationRecord
  belongs_to :usuario_whatsapp, optional: true
  belongs_to :comercio, optional: true

  validates :mensaje, presence: true
  enum estado: { nuevo: 0, enviado: 1, recibido: 2}
  
  def texto_para_envio
    <<~MSG
    Usuario: #{usuario_whatsapp.nombre}
    Celular: #{usuario_whatsapp.celular}
    Mensaje: #{mensaje}
    MSG
  end
end
