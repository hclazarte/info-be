class CreateEmailsBloqueados < ActiveRecord::Migration[7.0]
  def change
    create_table :emails_bloqueados do |t|
      t.string :email, null: false, index: { unique: true }
      t.text :motivo
      t.timestamps
    end
  end
end
