class CreateLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :logs do |t|
      t.string :texto, limit: 500         # Texto Búsqueda
      t.integer :resultado, null: false  # Encontrados
      t.string :ip, limit: 100, null: false # IP Cliente
      t.datetime :fecha, null: false     # Fecha
      t.string :aux, limit: 50           # Auxiliar
      
      t.timestamps
    end
  end
end
