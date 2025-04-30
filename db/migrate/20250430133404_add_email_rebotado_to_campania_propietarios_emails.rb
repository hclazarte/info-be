class AddEmailRebotadoToCampaniaPropietariosEmails < ActiveRecord::Migration[7.0]
  def change
    add_column :campania_propietarios_emails, :email_rebotado, :integer, default: 0, null: false
  end
end
