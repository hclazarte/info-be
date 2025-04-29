class CampaniaSeleccionadorWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default, retry: 2

  def perform
    seleccionados = CampaniaSeleccionador.seleccionar_comercios

    return if seleccionados.blank?
  end
end
