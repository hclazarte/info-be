class CampaniaPropietariosEmail < ApplicationRecord
  self.table_name = 'campania_propietarios_emails'

  validates :id_comercio, presence: true, uniqueness: true
  validates :email, presence: true
end
