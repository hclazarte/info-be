class UsuariosWhatsapp < ApplicationRecord
  has_many :whatsapp_chats, dependent: :destroy

  validates :celular, presence: true, uniqueness: true
  validates :nombre, presence: true
end
