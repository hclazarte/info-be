class ChangeSeprecEstToIntegerInComercios < ActiveRecord::Migration[7.0]
  def up
    # Cambiar el tipo de columna a integer
    change_column :comercios, :seprec_est, :integer, null: true
  end

  def down
    # Revertir el cambio de tipo de columna a decimal
    change_column :comercios, :seprec_est, :decimal, precision: 10, scale: 2, null: false
  end
end
