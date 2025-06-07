class WhatsappChat < ApplicationRecord
  belongs_to :comercio
  has_many :whatsapp_mensajes, dependent: :destroy

  validates :celular, presence: true
  validates :comercio_id, presence: true
end
