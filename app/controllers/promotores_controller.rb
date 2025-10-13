class PromotoresController < ApplicationController
  include RecaptchaVerifiable
  before_action :verify_recaptcha, only: :create

  def create
    existing = Promotor.find_by(email: promotor_params[:email])

    if existing
      if existing.solicitado?
        # Actualiza solo los campos editables desde la solicitud
        if existing.update(promotor_params.slice(:nombre, :telefono))
          render json: {
            id: existing.id,
            promotor: existing.as_json(only: [:id, :nombre, :email, :telefono, :estado, :created_at, :updated_at])
          }, status: :ok
        else
          render json: { errors: existing.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { errors: ['El correo está asignado a otra persona.'] }, status: :unprocessable_entity
      end
      return
    end

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
