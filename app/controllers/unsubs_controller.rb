# app/controllers/unsubs_controller.rb
class UnsubsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def confirm
    data = UnsubToken.decode(params[:token])
    return head :forbidden unless data&.dig('purpose') == 'unsubscribe'

    EmailBloqueado.find_or_create_by!(email: data['email']) do |e|
      e.motivo = params[:motivo]
    end
    head :ok
  end
end
