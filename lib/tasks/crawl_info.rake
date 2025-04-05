namespace :crawl do
  desc "Sincroniza datos con SEPREC"
  task info: :environment do
    CrawlInfo.run
    exit 1 unless success
  end
end
