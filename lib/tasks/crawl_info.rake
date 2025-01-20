namespace :crawl do
  desc "Sincroniza datos con SEPREC"
  task info: :environment do
    CrawlInfo.run
  end
end
