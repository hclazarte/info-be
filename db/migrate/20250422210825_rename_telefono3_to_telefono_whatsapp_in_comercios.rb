class RenameTelefono3ToTelefonoWhatsappInComercios < ActiveRecord::Migration[7.0]
  def change
    rename_column :comercios, :telefono3, :telefono_whatsapp
  end
end
