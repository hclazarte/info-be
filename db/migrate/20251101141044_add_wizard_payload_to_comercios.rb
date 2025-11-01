class AddWizardPayloadToComercios < ActiveRecord::Migration[7.0]
  def change
    add_column :comercios, :wizard_payload, :text
  end
end
