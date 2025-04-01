class AddPNaturalToComercios < ActiveRecord::Migration[7.0]
  def change
    add_column :comercios, :p_natural, :integer, default: 0, null: false
  end
end
