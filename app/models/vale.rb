class Vale < ApplicationRecord
  belongs_to :comercio, optional: true

  validates :codigo, presence: true, uniqueness: true
  validates :fecha_vencimiento, presence: true

  scope :vigentes, -> { where(usado: false).where('fecha_vencimiento >= ?', Time.current) }
  scope :vencidos, -> { where('fecha_vencimiento < ?', Time.current) }
  scope :usados,   -> { where(usado: true) }
  scope :no_usados, -> { where(usado: false) }

  before_validation :generar_codigo_unico, on: :create

  def transable?
    comercio_id.nil?
  end

  private

  def generar_codigo_unico
    return if codigo.present?

    loop do
      self.codigo = SecureRandom.alphanumeric(10).upcase
      break unless Vale.exists?(codigo: codigo)
    end
  end
end
