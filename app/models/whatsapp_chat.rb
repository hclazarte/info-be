class WhatsappChat < ApplicationRecord
  belongs_to :usuarios_whatsapp
  belongs_to :comercio

  validates :mensaje, presence: true

   def texto_para_envio
    <<~MSG
    Usuario: #{usuarios_whatsapp.nombre}
    Celular: #{usuarios_whatsapp.celular}
    Mensaje: #{mensaje}
    MSG
  end
end
