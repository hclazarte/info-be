class RenameZonaToZonaNombreInComercios < ActiveRecord::Migration[6.1]
  def change
    rename_column :comercios, :zona, :zona_nombre
  end
end
