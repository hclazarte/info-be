class CreateImpresiones < ActiveRecord::Migration[7.0]
  def change
    create_table :impresiones do |t|
      t.datetime :fecha, null: false       # Fecha
      t.string :ip, limit: 45, null: false # IP

      t.timestamps
    end
  end
end
