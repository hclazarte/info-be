class CampaniaValesMailer < ApplicationMailer
  helper :unsub
  default from: 'promociones@infomovil.com.bo'

  def promocion_vales(solicitud, vale, pdf_io)
    @solicitud = solicitud
    @vale = vale
    @comercio = Comercio.find(@solicitud.comercio_id)
    @base_url      = Rails.configuration.base_url

    unsubscribe_link = ApplicationController.helpers.unsubscribe_url(@solicitud.email)

    headers['List-Unsubscribe'] =
      "<#{unsubscribe_link}>, <mailto:promociones@infomovil.com.bo?subject=unsubscribe>"

    mail(
      to: @solicitud.email,
      bcc: 'administracion@infomovil.com.bo',
      subject: "Ha recibido un vale para registrar a : #{@comercio.empresa}",
    ) do |format|
      attachments['vale_infomovil.pdf'] = {
        mime_type: 'application/pdf',
        content: pdf_io.read
      }
      format.html do
        render html: render_to_string(
          template: 'campania_vales_mailer/promocion_vales',
          layout: 'mailer'
        ).html_safe, 
        content_type: 'text/html; charset=UTF-8; format=flowed',
        content_transfer_encoding: 'base64'
      end
    end
  end
end
