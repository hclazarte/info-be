namespace :crawl do
  desc 'Sincroniza datos con SEPREC'
  task info: :environment do
    success = CrawlInfo.run
    exit 1 unless success
  end
end
