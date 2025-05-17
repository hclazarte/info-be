class EmailsBloqueadosController < ApplicationController
  # POST /api/emails_bloqueados
  def create
    email = params[:email]&.strip&.downcase

    return render json: { error: 'Correo no proporcionado' }, status: :unprocessable_entity if email.blank?

    bloqueado = EmailBloqueado.find_by(email: email)
    if bloqueado
      render json: { error: 'El correo ya está bloqueado' }, status: :conflict
    else
      nuevo = EmailBloqueado.new(email: email, motivo: params[:motivo])
      if nuevo.save
        render json: { message: 'Correo bloqueado exitosamente' }, status: :created
      else
        render json: { error: 'No se pudo bloquear el correo', detalles: nuevo.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  # DELETE /api/emails_bloqueados/:email
  def destroy
    email = params[:email]&.strip&.downcase

    bloqueado = EmailBloqueado.find_by(email: email)
    if bloqueado
      bloqueado.destroy
      render json: { message: 'Correo desbloqueado exitosamente' }
    else
      render json: { error: 'Correo no encontrado en la lista de bloqueados' }, status: :not_found
    end
  end
end
