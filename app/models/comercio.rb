class Comercio < ApplicationRecord
  # relaciones
  belongs_to :zona, optional: true
  belongs_to :ciudad

  scope :activos, -> { where(activo: true, bloqueado: false) }

  def activo?
    activo && !bloqueado
  end

  def autorizado?
    autorizado == 1
  end

  def documentos_validados?
    documentos_validados == 1
  end

  # Ignorar campos no utilizados o redundantes
  self.ignored_columns = %w[com_descr]
end
