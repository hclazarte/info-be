class AddTotalToCiudades < ActiveRecord::Migration[7.0]
  def change
    add_column :ciudades, :total, :integer, default: 0, null: false
  end
end
