class AddIndexAutorizadoIdToComercios < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE INDEX idx_comercios_autorizado_id
      ON COMERCIOS (AUTORIZADO DESC, ID DESC)
    SQL
  end
  def down
    execute <<-SQL
      DROP INDEX idx_comercios_autorizado_id
    SQL
  end
end
