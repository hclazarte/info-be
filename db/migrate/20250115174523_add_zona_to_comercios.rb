class AddZonaToComercios < ActiveRecord::Migration[7.0]
  def change
    add_column :comercios, :zona_id, :integer
    add_foreign_key :comercios, :zonas, column: :zona_id
  end
end
