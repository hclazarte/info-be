class MakeNumeroComercioNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :comercios, :numero_comercio, true
  end
end
