class Solicitud < ApplicationRecord
  self.table_name = "solicitudes"
  
  belongs_to :comercio, optional: true

  enum estado: {
    pendiente_verificacion: 0,
    documentos_validados:   1,
    pago_pendiente:         2,
    pago_en_revision:       3,
    comercio_habilitado:    4,
    rechazada:              5
  }

  validates :email, presence: true
end
