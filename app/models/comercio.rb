class Comercio < ApplicationRecord
  CAMPOS_DE_PAGO = %i[pagina_web telefono_whatsapp servicios].freeze
  # relaciones
  belongs_to :zona, optional: true
  belongs_to :ciudad
  has_many :solicitudes, class_name: 'Solicitud', foreign_key: :comercio_id
  has_many :whatsapp_chats, dependent: :destroy

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

  def whatsapp_autorizado?
    whatsapp_fecha_autorizado.present? && whatsapp_fecha_autorizado > 24.hours.ago
  end

  # Ignorar campos no utilizados o redundantes
  self.ignored_columns = %w[com_descr]
end
