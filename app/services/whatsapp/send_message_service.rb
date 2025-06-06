require 'net/http'
require 'uri'
require 'json'

module Whatsapp
  class SendMessageService
    API_URL = 'https://graph.facebook.com/v22.0' # actualízalo si Meta cambia la versión

    def initialize(to:, template_name:, template_language:, template_variables: [])
      @to = to
      @template_name = template_name
      @template_language = template_language
      @template_variables = template_variables
      @access_token = ENV['WHATSAPP_ACCESS_TOKEN']
      @phone_number_id = ENV['WHATSAPP_PHONE_NUMBER_ID'] # debes definirlo también (te explico abajo)
    end

    def call
      uri = URI.parse("#{API_URL}/#{@phone_number_id}/messages")

      header = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer #{@access_token}"
      }

      body = {
        messaging_product: 'whatsapp',
        to: @to,
        type: 'template',
        template: {
          name: @template_name,
          language: { code: @template_language },
          components: [
            {
              type: 'body',
              parameters: @template_variables.map do |var|
                {
                  type: 'text',
                  parameter_name: var[:parameter_name],
                  text: var[:text]
                }
              end
            }
          ]
        }
      }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = body.to_json

      response = http.request(request)

      Rails.logger.info "WhatsApp API response: #{response.code} - #{response.body}"

      response.code == '200'
    rescue StandardError => e
      Rails.logger.error "WhatsApp API call failed: #{e.message}"
      false
    end
  end
end
