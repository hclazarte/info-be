class CreateVales < ActiveRecord::Migration[7.0]
  def change
    create_table :vales do |t|
      t.string     :codigo,            null: false, index: { unique: true }
      t.references :comercio,          foreign_key: true, null: true
      t.boolean    :usado,             default: false, null: false
      t.datetime   :usado_en
      t.datetime   :fecha_vencimiento, null: false
      t.string     :motivo

      t.timestamps
    end
  end
end
