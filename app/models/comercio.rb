class Comercio < ApplicationRecord
  # relaciones
  belongs_to :zona, optional: true
  belongs_to :ciudad 

  scope :activos, -> { where(activo: true, bloqueado: false) }
  
  class Comercio < ApplicationRecord
    def activo?
      activo && !bloqueado
    end
  end

  # Ignorar campos no utilizados o redundantes
  self.ignored_columns = %w[com_descr]
end
