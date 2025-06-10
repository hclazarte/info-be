class CreateUsuariosWhatsapp < ActiveRecord::Migration[7.0]
 def change
    create_table :usuarios_whatsapp do |t|
      t.string :celular, null: false
      t.string :nombre
      t.boolean :whatsapp_verificado, default: false
      t.datetime :whatsapp_fecha_autorizado

      t.timestamps
    end

    add_index :usuarios_whatsapp, :celular, unique: true
  end
end
