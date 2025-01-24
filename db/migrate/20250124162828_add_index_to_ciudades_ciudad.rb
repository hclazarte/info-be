class AddIndexToCiudadesCiudad < ActiveRecord::Migration[7.0]
  def change
    add_index :ciudades, :ciudad, unique: false
  end
end
