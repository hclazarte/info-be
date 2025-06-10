class AddWhatsappFechaAutorizadoToComercios < ActiveRecord::Migration[7.0]
  def change
    add_column :comercios, :whatsapp_fecha_autorizado, :datetime
  end
end
