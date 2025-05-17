class EmailBloqueado < ApplicationRecord
  before_validation :normalizar_email
  self.table_name = 'emails_bloqueados'

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: {
    with: URI::MailTo::EMAIL_REGEXP,
    message: 'no tiene un formato válido'
  }

  private

  def normalizar_email
    self.email = email.to_s.strip.downcase
  end
end
