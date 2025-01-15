class Ciudad < ApplicationRecord
  self.table_name = "ciudades"

  # Validaciones
  validates :ciudad, presence: true # Asegura que el campo 'ciudad' no sea nulo

  # Opcional: scopes para facilitar consultas
  scope :by_name, ->(name) { where("UPPER(ciudad) LIKE ?", "%#{name.upcase}%") } # Buscar ciudades por nombre

  # has_many :comercios
end
