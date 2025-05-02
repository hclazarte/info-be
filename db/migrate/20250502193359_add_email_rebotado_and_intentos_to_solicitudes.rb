class AddEmailRebotadoAndIntentosToSolicitudes < ActiveRecord::Migration[7.0]
  def change
    add_column :solicitudes, :email_rebotado, :integer, default: 0
    add_column :solicitudes, :intentos, :integer, default: 0
  end
end
