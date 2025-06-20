# app/controllers/api/log_clics_controller.rb
class LogClicsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :verify_recaptcha, only: :create
  before_action :validate_params!

  def create
    Rails.logger.info "XFF HEADER raw: #{request.headers['X-Forwarded-For'].inspect}"
    ip = extract_client_ip

    # Si es IP de testing o localhost, no hacemos nada
    # if excluded_ip?(ip)
    #   Rails.logger.info "IP excluida, omitiendo registro de clic: #{ip}"
    #   head :no_content and return
    # end

    log = LogClic.new(
      comercio_id: params[:comercio_id],
      plataforma: params[:plataforma],
      ip:        ip,
      fecha:     Time.current
    )

    if log.save
      render json: { id: log.id }, status: :created
    else
      Rails.logger.error "LogClic no guardado: #{log.errors.full_messages.join(', ')}"
      render json: { errors: log.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
  def extract_client_ip
    if request.headers['X-Forwarded-For'].present?
      request.headers['X-Forwarded-For'].split(',').first.strip
    else
      request.remote_ip
    end
  end

  def validate_params!
    params.require(:comercio_id)
    params.require(:plataforma)
  rescue ActionController::ParameterMissing => e
    render json: { error: e.message }, status: :bad_request
  end

  def excluded_ip?(ip)
    ip.include?('190.181.25.130') ||
    ip.start_with?('192.168.0') ||
    ip.include?('127.0.0.1') ||
    ip.include?('::1')
  end
end
