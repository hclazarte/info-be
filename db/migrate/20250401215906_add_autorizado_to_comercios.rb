class AddAutorizadoToComercios < ActiveRecord::Migration[7.0]
  def change
    add_column :comercios, :autorizado, :integer, default: 0, null: false
  end
end
