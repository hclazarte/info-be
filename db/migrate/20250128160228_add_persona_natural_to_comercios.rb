class AddPersonaNaturalToComercios < ActiveRecord::Migration[7.0]
  def change
    add_column :comercios, :persona_natural, :string
  end
end
