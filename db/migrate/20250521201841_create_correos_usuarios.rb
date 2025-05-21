class CreateCorreosUsuarios < ActiveRecord::Migration[7.0]
  def change
    create_table :correos_usuarios do |t|
      t.string   :remitente,     null: false
      t.string   :destinatario,  null: false
      t.string   :asunto,        null: false
      t.text     :cuerpo,        null: false
      t.integer  :estado,        default: 0, null: false
      t.integer  :intentos,      default: 0, null: false
      t.datetime :fecha
      t.string   :nombre
      t.references :comercio, foreign_key: true

      t.timestamps
    end
  end
end
