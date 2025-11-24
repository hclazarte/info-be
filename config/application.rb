require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
# require "active_storage/engine"
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
require 'action_cable/engine'
require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)

module Info
  class Application < Rails::Application
    config.load_defaults 7.0
    config.time_zone = 'America/La_Paz'
    config.active_job.queue_adapter = :sidekiq
  end
end

# CORS para DEVELOPMENT
if Rails.env.development?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins 'http://localhost:3000',
              'http://localhost:3001',
              'http://localhost:5173',
              'https://geosoft.website'

      resource '*',
               headers: :any,
               methods: %i[get post put patch delete options head]
    end
  end
end

# CORS para PRODUCTION
if Rails.env.production?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins 'https://geosoft.website'

      resource '*',
               headers: :any,
               methods: %i[get post put patch delete options head]
    end
  end
end

Sidekiq.configure_server do |config|
  if Rails.env.production?
  end

  redis_url = 'redis://redis:6379/0'
  config.redis = { url: redis_url }
end
