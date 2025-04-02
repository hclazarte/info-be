class AddConstraintsToEmpresaInComercios < ActiveRecord::Migration[7.0]
  def change
    change_column_null :comercios, :empresa, false
  end
end
