class Comercio < ApplicationRecord
  # relaciones
  belongs_to :zona, optional: true
  belongs_to :ciudad 

  # Ignorar campos no utilizados o redundantes
  self.ignored_columns = %w[shape com_descr]
end
