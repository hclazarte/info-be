class RemoveFuenteFromLogClics < ActiveRecord::Migration[7.0]
  def change
    remove_column :log_clics, :fuente, :string
  end
end
