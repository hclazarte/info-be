class CampaniaMailer < ApplicationMailer
  default from: 'promociones@infomovil.com.bo'

  def promocion_comercio(campania)
    @campania = campania
    @comercio = Comercio.find(campania.id_comercio)
    @base_url = Rails.configuration.base_url
    @ciudad_nombre = @comercio.ciudad&.ciudad

    @ciudad_slug = @ciudad_nombre.to_s.parameterize
    @comercio_slug = @comercio.empresa.to_s.parameterize

    mail(
      to: @campania.email,
      subject: "Registre a #{@comercio.empresa} en Infomóvil"
    )
  end
end