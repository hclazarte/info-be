class RenamePNaturalToPersonaNaturalInComercios < ActiveRecord::Migration[7.0]
  def change
    rename_column :comercios, :p_natural, :persona_natural
  end
end
