module Whatsapp
  class MensajesController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      comercio_id = params[:comercio_id]
      celular = params[:celular]
      nombre = params[:nombre]
      cuerpo = params[:mensaje]

      if comercio_id.blank? || celular.blank? || cuerpo.blank?
        return render json: { error: 'Parámetros requeridos: comercio_id, celular, mensaje' }, status: :unprocessable_entity
      end

      # Busca o crea el chat sin insertar mensaje inicial
      chat = WhatsappChat.find_or_create_by!(comercio_id: comercio_id, celular: celular) do |nuevo_chat|
        nuevo_chat.nombre = nombre
      end

      # Guarda el mensaje del usuario
      mensaje = chat.whatsapp_mensajes.create!(
        cuerpo: cuerpo,
        remitente: :usuario
      )

      render json: { id: mensaje.id }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
