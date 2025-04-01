class RemovePersonaNaturalFromComercios < ActiveRecord::Migration[7.0]
  def change
    remove_column :comercios, :persona_natural, :string
  end
end
