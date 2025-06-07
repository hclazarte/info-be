class AddWhatsappVerificadoToWhatsappChats < ActiveRecord::Migration[7.0]
  def change
    add_column :whatsapp_chats, :whatsapp_verificado, :boolean, default: false, null: false
  end
end
