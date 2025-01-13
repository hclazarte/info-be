class Padron < ApplicationRecord
  # Ignorar campos no utilizados o redundantes
  self.ignored_columns = %w[pad_descr]
end
