class Ciudad < ApplicationRecord
  self.table_name = 'ciudades'

  # Validaciones
  validates :ciudad, presence: true # Asegura que el campo 'ciudad' no sea nulo

  # Relaciones
  has_many :zonas, foreign_key: 'ciudad_id', class_name: 'Zona'
  has_many :comercios, foreign_key: 'ciudad_id', class_name: 'Comercio'

  # Opcional: scopes para facilitar consultas
  scope :by_name, ->(name) { where('UPPER(ciudad) LIKE ?', "%#{name.upcase}%") } # Buscar ciudades por nombre
end
