class CrawlInfoWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: 3

  def perform
    Rails.logger.info 'Iniciando migración de SEPREC con Sidekiq...'

    # Ejecutar la tarea rake dentro del worker
    system('bundle exec rake crawl:info')

    Rails.logger.info 'Migración de SEPREC finalizada con éxito.'
  end
end
