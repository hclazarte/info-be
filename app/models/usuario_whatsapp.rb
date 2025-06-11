class UsuarioWhatsapp < ApplicationRecord
  self.table_name = 'usuarios_whatsapp'
  has_many :whatsapp_chats, dependent: :destroy

  validates :celular, presence: true, uniqueness: true
  validates :nombre, presence: true


  def whatsapp_autorizado?
    whatsapp_fecha_autorizado.present? && whatsapp_fecha_autorizado > 24.hours.ago
  end
end
