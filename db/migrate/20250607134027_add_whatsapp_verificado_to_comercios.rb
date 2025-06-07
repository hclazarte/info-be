class AddWhatsappVerificadoToComercios < ActiveRecord::Migration[7.0]
  def change
    add_column :comercios, :whatsapp_verificado, :boolean, default: true, null: false
  end
end
