class CreateCorreos < ActiveRecord::Migration[7.0]
  def change
    create_table :correos do |t|
      t.string :remitente, null: false
      t.string :asunto, null: false
      t.integer :tipo, null: false  # ENUM para sugerencia, consulta, reclamo, etc.
      t.text :cuerpo, null: false
      t.integer :estado, default: 0 # ENUM: 0=Pendiente, 1=Enviado, 2=Fallido
      t.integer :intentos, default: 0
      t.datetime :fecha, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
  end
end
