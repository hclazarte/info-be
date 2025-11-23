class AddNumeroCelularToCorreosUsuarios < ActiveRecord::Migration[7.0]
  def change
    add_column :correos_usuarios, :numero_celular, :string
  end
end
