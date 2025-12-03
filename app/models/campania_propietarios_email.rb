class CampaniaPropietariosEmail < ApplicationRecord
  self.table_name = 'campania_propietarios_emails'

  belongs_to :comercio, class_name: "Comercio", foreign_key: "comercio_id"

  validates :comercio_id, presence: true, uniqueness: true
  validates :email, presence: true

  def email_rebotado?
    email_rebotado == 1
  end
end
