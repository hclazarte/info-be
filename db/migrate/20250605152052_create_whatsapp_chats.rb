class CreateWhatsappChats < ActiveRecord::Migration[7.0]
  def change
    create_table :whatsapp_chats do |t|
      t.references :comercio, null: false, foreign_key: true
      t.string :nombre
      t.string :celular, null: false

      t.timestamps
    end
  end
end
