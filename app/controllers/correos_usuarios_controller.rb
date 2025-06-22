class CorreosUsuariosController < ApplicationController
  include RecaptchaVerifiable

  before_action :verify_recaptcha, only: :create

  def create
    comercio_id = params.dig(:correos_usuario, :comercio_id)
    comercio = Comercio.find_by(id: comercio_id)

    if comercio.nil? || comercio.email_verificado.blank?
      return render json: { error: 'Comercio sin correo verificado' }, status: :unprocessable_entity
    end

    correo = CorreoUsuario.new(correo_params.merge(destinatario: comercio.email_verificado))

    if correo.save
      begin
        EmailProtegido.deliver_later(CorreoUsuarioMailer, :enviar_mensaje_usuario, correo)
        puts "Enviando correo a #{correo.destinatario}"
      rescue EmailProtegido::EmailBloqueadoError => e
        puts e.message
      end
      render json: { ok: true, id: correo.id }, status: :created
    else
      puts correo.errors.full_messages
      render json: { errors: correo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def correo_params
    params.require(:correos_usuario).permit(:nombre, :remitente, :asunto, :cuerpo, :comercio_id)
  end
end
