class Comercio < ApplicationRecord
  # relaciones
  belongs_to :zona, optional: true
  belongs_to :ciudad
  has_many :solicitudes, class_name: 'Solicitud', foreign_key: :comercio_id


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
  
  def seprec?
    seprec.present?
  end  
  
  def campania_iniciada?
    campania_iniciada == 1
  end

  # Ignorar campos no utilizados o redundantes
  self.ignored_columns = %w[com_descr]
end
