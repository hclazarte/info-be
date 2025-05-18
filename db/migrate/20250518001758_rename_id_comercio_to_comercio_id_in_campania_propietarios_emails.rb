class RenameIdComercioToComercioIdInCampaniaPropietariosEmails < ActiveRecord::Migration[7.0]
 def up
    # 1) Quitar índice único existente
    if index_exists?(:campania_propietarios_emails, :id_comercio, unique: true)
      remove_index :campania_propietarios_emails, column: :id_comercio
    end

    # 2) Renombrar la columna
    rename_column :campania_propietarios_emails, :id_comercio, :comercio_id

    # 3) Crear nuevo índice único sobre la columna normalizada
    add_index :campania_propietarios_emails, :comercio_id, unique: true
  end

  def down
    remove_index :campania_propietarios_emails, :comercio_id
    rename_column :campania_propietarios_emails, :comercio_id, :id_comercio
    add_index :campania_propietarios_emails, :id_comercio, unique: true
  end
end
