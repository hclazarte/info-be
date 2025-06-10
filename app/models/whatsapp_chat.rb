class WhatsappChat < ApplicationRecord
  belongs_to :usuarios_whatsapp
  belongs_to :comercio

  validates :mensaje, presence: true
end
