class AddDocumentosValidadosToComercios < ActiveRecord::Migration[7.0]
  def change
    add_column :comercios, :documentos_validados, :integer, default: 0, null: false
  end
end
