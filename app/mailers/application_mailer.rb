class ApplicationMailer < ActionMailer::Base
  default from: 'portal@infomovil.com.bo' # Correo verificado en AWS SES
  layout 'mailer' # Usa un layout para los correos
end
