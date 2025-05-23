# app/mailers/administracion_mailer.rb
class AdministracionMailer < ApplicationMailer
  default to: 'admin@infomovil.com.bo'

  def notificacion(mensaje)
    @mensaje = mensaje
    @fecha = Time.current.strftime("%Y-%m-%d %H:%M:%S")
    mail(subject: "Notificación administrativa – #{@fecha}")
  end
end
