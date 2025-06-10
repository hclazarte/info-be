class ModifyWhatsappChats < ActiveRecord::Migration[7.0]
  def change
    remove_column :whatsapp_chats, :celular, :string
    remove_column :whatsapp_chats, :whatsapp_verificado, :boolean

    add_reference :whatsapp_chats, :usuarios_whatsapp, foreign_key: true
    add_column :whatsapp_chats, :mensaje, :text
  end
end
