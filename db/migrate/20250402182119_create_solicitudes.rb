class CreateSolicitudes < ActiveRecord::Migration[7.0]
  def change
    create_table :solicitudes do |t|
      t.string :email, null: false
      t.references :comercio, foreign_key: true
      t.binary :nit_imagen
      t.binary :ci_imagen
      t.boolean :nit_ok, default: false
      t.boolean :ci_ok, default: false
      t.string :nombre
      t.integer :estado, default: 0
      t.string :otp_token
      t.datetime :otp_expires_at

      t.timestamps
    end
  end
end
