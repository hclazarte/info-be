class CreateLogClics < ActiveRecord::Migration[7.0]
  def change
    create_table :log_clics do |t|
      t.string :ip, limit: 45, null: false      # IP
      t.datetime :fecha, null: false           # Fecha
      t.string :fuente, limit: 50              # Fuente

      t.timestamps
    end
  end
end
