class AddForeignKeys < ActiveRecord::Migration[7.0]
  def change
    # Relación Comercios → Ciudades
    add_reference :comercios, :ciudad, null: false, foreign_key: { to_table: :ciudades }

    # Relación Impresiones → Comercios
    add_reference :impresiones, :comercio, null: false, foreign_key: { to_table: :comercios }

    # Relación LogClics → Comercios
    add_reference :log_clics, :comercio, null: false, foreign_key: { to_table: :comercios }

    # Relación Logs → Zonas
    add_reference :logs, :zona, foreign_key: { to_table: :zonas }

    # Relación Logs → Ciudades
    add_reference :logs, :ciudad, foreign_key: { to_table: :ciudades }

    # Relación Zonas → Ciudades
    add_reference :zonas, :ciudad, null: false, foreign_key: { to_table: :ciudades }
  end
end
