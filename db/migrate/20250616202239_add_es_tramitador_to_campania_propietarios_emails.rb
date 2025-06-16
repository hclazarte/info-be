class AddEsTramitadorToCampaniaPropietariosEmails < ActiveRecord::Migration[7.0]
  def change
    add_column :campania_propietarios_emails, :es_tramitador, :boolean, default: false, null: false
  end
end
