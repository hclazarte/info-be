class DropWhatsappMensajes < ActiveRecord::Migration[7.0]
  def change
    drop_table :whatsapp_mensajes
  end
end
