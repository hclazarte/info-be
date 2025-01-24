class AddIndexToZonasDescripcion < ActiveRecord::Migration[7.0]
  def change
    add_index :zonas, :descripcion, unique: false
  end
end
