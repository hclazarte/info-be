class RenameUsuariosWhatsappIdToUsuarioWhatsappIdInWhatsappChats < ActiveRecord::Migration[7.0]
  def change
    rename_column :whatsapp_chats, :usuarios_whatsapp_id, :usuario_whatsapp_id
  end
end
