class AddEmailVerificadoToComercios < ActiveRecord::Migration[7.0]
  def change
    add_column :comercios, :email_verificado, :string
  end
end
