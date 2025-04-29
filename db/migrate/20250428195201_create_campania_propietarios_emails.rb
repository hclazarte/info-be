class CreateCampaniaPropietariosEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :campania_propietarios_emails do |t|
      t.bigint :id_comercio, null: false
      t.string :email, null: false
      t.boolean :enviado, default: false, null: false
      t.boolean :clic, default: false, null: false
      t.integer :intentos_envio, default: 0, null: false
      t.datetime :ultima_fecha_envio

      t.timestamps
    end

    add_index :campania_propietarios_emails, :id_comercio, unique: true
  end
end
