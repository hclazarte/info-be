class EnviarTokenJob
  include Sidekiq::Job

  def perform(solicitud_id)
    solicitud = Solicitud.find_by(id: solicitud_id)
    return unless solicitud

    SolicitudMailer.enviar_token(solicitud).deliver_now
  end
end
