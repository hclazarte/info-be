class PromotoresController < ApplicationController
  include RecaptchaVerifiable

  # Si tu mixin expone un before_action, úsalo así:
  before_action :verify_recaptcha, only: :create

  def create
    promotor = Promotor.new(promotor_params)
    promotor.estado ||= :solicitado

    if promotor.save
      render json: {
        id: promotor.id,
        promotor: promotor.as_json(only: [:id, :nombre, :email, :telefono, :estado, :created_at, :updated_at])
      }, status: :created
    else
      render json: { errors: promotor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def promotor_params
    params.require(:promotor).permit(:nombre, :email, :telefono)
  end
end
