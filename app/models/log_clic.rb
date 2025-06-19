class LogClic < ApplicationRecord
  self.table_name = 'log_clics'
  belongs_to :comercio

  enum plataforma: { escritorio: 0, movil: 1 }

  validates :ip, presence: true
  validates :comercio_id, presence: true
  validates :plataforma, inclusion: { in: plataformas.keys }
end
