class EmailProtegido
  class EmailBloqueadoError < StandardError; end

  def self.deliver_now(mailer_class, method_name, *args)
    mail = mailer_class.public_send(method_name, *args)
    verificar_destinatarios!(mail.to)
    mail.deliver_now
  end

  def self.deliver_later(mailer_class, method_name, *args)
    mail = mailer_class.public_send(method_name, *args)
    verificar_destinatarios!(mail.to)
    mail.deliver_later
  end

  private

  def self.verificar_destinatarios!(destinatarios)
    return if destinatarios.blank?

    normalizados = Array(destinatarios).map { |e| e.to_s.strip.downcase }
    bloqueados = EmailBloqueado.where(email: normalizados).pluck(:email)

    if bloqueados.any?
      raise EmailBloqueadoError, "Envío bloqueado: #{bloqueados.join(', ')}"
    end
  end
end
