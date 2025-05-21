class CorreosUsuariosController < ApplicationController
  include RecaptchaVerifiable

  protect_from_forgery with: :null_session

  def create
    comercio = Comercio.find_by(id: params[:comercio_id])

    if comercio.nil? || comercio.email.blank? || comercio.email_verificado.blank?
      return render json: { error: 'Comercio sin correo verificado' }, status: :unprocessable_entity
    end

    correo = CorreoUsuario.new(
      remitente: params[:remitente],
      destinatario: comercio.email, # ahora se obtiene internamente
      asunto: params[:asunto],
      cuerpo: params[:cuerpo],
      nombre: params[:nombre],
      comercio_id: comercio.id,
      fecha: Time.current,
      estado: :pendiente
    )

    if correo.save
      begin
        EmailProtegido.deliver_later(CorreoUsuarioMailer, :enviar_mensaje_usuario, correo)
        puts "Enviando correo a #{correo.destinatario}"
      rescue EmailProtegido::EmailBloqueadoError => e
        puts e.message         # “Envío bloqueado: …”
      end
      render json: { ok: true, id: correo.id }, status: :created
    else
      render json: { errors: correo.errors.full_messages }, status: :unprocessable_entity
    end
  end
end

