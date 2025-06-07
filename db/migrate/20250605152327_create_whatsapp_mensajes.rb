class CreateWhatsappMensajes < ActiveRecord::Migration[7.0]
  def change
    create_table :whatsapp_mensajes do |t|
      t.references :whatsapp_chat, null: false, foreign_key: true
      t.text :cuerpo, null: false
      t.integer :remitente, null: false, default: 0  # 0 = usuario, 1 = comercio

      t.timestamps
    end
  end
end
