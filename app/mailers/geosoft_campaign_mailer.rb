class GeosoftCampaignMailer < ApplicationMailer
  helper :unsub
  default from: "campanias@geosoft.website"
  
  def campania_propietario(campania_propietarios_email)
    @campania = campania_propietarios_email
    @comercio = campania_propietarios_email.comercio

    # Nombre para personalizar el saludo
    @nombre_comercio =
      if @comercio&.respond_to?(:empresa) && @comercio.empresa.present?
        @comercio.empresa
      else
        "su comercio"
      end

    destinatario = campania_propietarios_email.email.presence ||
                   (@comercio&.respond_to?(:email) ? @comercio.email : nil)

    # Por seguridad, si no hay destinatario, lanzamos error para que el rake lo capture
    if destinatario.blank?
      raise "No se encontró email destino para CampaniaPropietariosEmail ID=#{campania_propietarios_email.id}"
    end

    mail(
      to: destinatario,
      subject: "Geosoft: impulse la presencia digital de #{@nombre_comercio}"
    )
  end
end
