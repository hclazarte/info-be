class Solicitud < ApplicationRecord
  self.table_name = 'solicitudes'

  belongs_to :comercio, optional: true

  enum estado: {
    pendiente_verificacion: 0,
    documentos_validados: 1,
    pago_validado: 2,
    comercio_habilitado: 3,
    rechazada: 5
  }

  validates :email, presence: true
  validates :email, uniqueness: { scope: :comercio_id, message: "ya existe una solicitud para este comercio con este email" }

  def email_rebotado?
    email_rebotado == 1
  end

  def gratuito?
    fecha_fin_servicio.nil? || fecha_fin_servicio < Time.zone.now
  end
end
