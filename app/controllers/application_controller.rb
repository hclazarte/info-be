class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  private

  def client_ip
    header = request.headers['X-Forwarded-For']
    header.present? ? header.split(',').first.strip : request.remote_ip
  end
end
