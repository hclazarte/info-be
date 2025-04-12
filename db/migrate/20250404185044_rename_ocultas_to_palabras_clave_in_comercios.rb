class RenameOcultasToPalabrasClaveInComercios < ActiveRecord::Migration[7.0]
  def change
    rename_column :comercios, :ocultas, :palabras_clave
  end
end
rails db: migrate
