class AddEstadoToWhatsappChats < ActiveRecord::Migration[7.0]
  def change
    add_column :whatsapp_chats, :estado, :integer
  end
end
