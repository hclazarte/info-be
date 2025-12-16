class AddTipoUnidadEconomicaToComercios < ActiveRecord::Migration[7.0]
  def change
    add_column :comercios, :tipo_unidad_economica, :string
  end
end
