class CreatePromotores < ActiveRecord::Migration[7.0]
  def change
    create_table :promotores do |t|
      t.string  :nombre,   null: false
      t.string  :email,    null: false
      t.string  :telefono, null: false
      # 0: solicitado, 1: aprobado, 2: rechazado
      t.integer :estado,   null: false, default: 0

      t.timestamps
    end

    add_index :promotores, :email, unique: true
  end
end
