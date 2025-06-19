class AddPlataformaToLogClics < ActiveRecord::Migration[7.0]
  def change
    add_column :log_clics, :plataforma, :integer, null: false, default: 0
  end
end
