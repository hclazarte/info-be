class CampaniaPropietariosEmail < ApplicationRecord
  self.table_name = 'campania_propietarios_emails'

  validates :id_comercio, presence: true, uniqueness: true
  validates :email, presence: true

  def email_rebotado?
    email_rebotado == 1
  end
end
