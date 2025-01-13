class CreateCiudades < ActiveRecord::Migration[7.0]
  def change
    create_table :ciudades do |t|
      t.string :ciudad, null: false # Ciudad
      t.string :cod_municipio       # Ref Inicial
      t.string :pais                # País
      t.string :cod_pais            # Código País
      t.binary :imagen              # Imagen (antes CLOB)
      
      t.timestamps
    end
  end
end
