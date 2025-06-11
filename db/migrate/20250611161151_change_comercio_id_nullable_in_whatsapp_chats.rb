class ChangeComercioIdNullableInWhatsappChats < ActiveRecord::Migration[7.0]
  def change
    change_column_null :whatsapp_chats, :comercio_id, true
  end
end
