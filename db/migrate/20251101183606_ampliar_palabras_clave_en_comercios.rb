class AmpliarPalabrasClaveEnComercios < ActiveRecord::Migration[7.0]
  def up
    change_column :comercios, :palabras_clave, :string, limit: 2000
  end

  def down
    change_column :comercios, :palabras_clave, :string, limit: 500
  end
end
