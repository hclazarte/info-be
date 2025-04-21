class AddUniqueIndexToSolicitudesOnEmailAndComercioId < ActiveRecord::Migration[7.0]
  def change
    add_index :solicitudes, [:email, :comercio_id], unique: true, name: 'index_solicitudes_on_email_and_comercio_id_unique'
  end
end
