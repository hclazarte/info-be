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

    def send_template_message
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

      # Imprimir el JSON generado (para comparar con el curl)
      Rails.logger.info "WhatsApp API request body:\n#{JSON.pretty_generate(body)}"

      conn = Faraday.new(url: API_URL) do |f|
        f.request :json
        f.response :logger, Rails.logger, bodies: true # opcional: log de request/response
        f.adapter Faraday.default_adapter
      end

      response = conn.post("#{@phone_number_id}/messages") do |req|
        req.headers['Authorization'] = "Bearer #{@access_token}"
        req.headers['Content-Type'] = 'application/json'
        req.body = body
      end

      Rails.logger.info "WhatsApp API response: #{response.status} - #{response.body}"

      response.status == 200
    rescue StandardError => e
      Rails.logger.error "WhatsApp API call failed: #{e.message}"
      false
    end

    def send_text_message(text)
      conn = Faraday.new(url: API_URL) do |f|
        f.request :json
        f.response :logger, Rails.logger, bodies: true # opcional: para loggear requests/responses
        f.adapter Faraday.default_adapter
      end

      response = conn.post("#{@phone_number_id}/messages") do |req|
        req.headers['Authorization'] = "Bearer #{@access_token}"
        req.headers['Content-Type'] = 'application/json'
        req.body = {
          messaging_product: 'whatsapp',
          to: @to,
          type: 'text',
          text: {
            body: text
          }
        }
      end

      Rails.logger.info "WhatsApp API response (text): #{response.status} - #{response.body}"

      response.status == 200
    rescue StandardError => e
      Rails.logger.error "WhatsApp API send_text_message failed: #{e.message}"
      false
    end
  end
end
