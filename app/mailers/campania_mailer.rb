class CampaniaMailer < ApplicationMailer
  helper :unsub
  default from: 'promociones@infomovil.com.bo'

  def promocion_comercio(campania)
    @campania = campania
    @comercio = Comercio.find(campania.comercio_id)
    @base_url = Rails.configuration.base_url
    @ciudad_nombre = @comercio.ciudad&.ciudad
    @ciudad_slug = @ciudad_nombre.to_s.parameterize
    @comercio_slug = @comercio.empresa.to_s.parameterize

    # enlace HTTPS firmado
    unsubscribe_link = helper.unsubscribe_url(@campania.email)

    # cabecera List-Unsubscribe: incluye https y mailto
    headers['List-Unsubscribe'] =
      "<#{unsubscribe_link}>, <mailto:promociones@infomovil.com.bo?subject=unsubscribe>"

    mail(
      to: @campania.email,
      subject: "Registre a #{@comercio.empresa} en Infomóvil",
      content_transfer_encoding: 'base64',
      charset: 'UTF-8'
    )
  end
end
