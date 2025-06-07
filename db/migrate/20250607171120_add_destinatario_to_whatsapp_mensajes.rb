class AddDestinatarioToWhatsappMensajes < ActiveRecord::Migration[7.0]
 def change
    add_column :whatsapp_mensajes, :destinatario, :integer, null: true
  end
end
