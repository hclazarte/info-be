class Promotor < ApplicationRecord
  self.table_name = 'promotores'

  enum estado: { solicitado: 0, aprobado: 1, rechazado: 2, suspendido: 3 }

  validates :nombre, presence: true
  validates :email, presence: true, uniqueness: true
  validates :telefono, presence: true
end
