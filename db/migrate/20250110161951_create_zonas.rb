class CreateZonas < ActiveRecord::Migration[7.0]
  def change
    create_table :zonas do |t|
      t.string :descripcion, limit: 50, null: false # Descripción
      t.integer :total, default: 0 # Total Comercios

      t.timestamps
    end
  end
end
