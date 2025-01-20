class CreateComercios < ActiveRecord::Migration[7.0]
  def change
    create_table :comercios do |t|
      t.decimal :latitud, precision: 10, scale: 6   # Latitud
      t.decimal :longitud, precision: 10, scale: 6  # Longitud
      t.date :fecha_registro, null: false           # Fecha de registro
      t.date :fecha_encuesta, null: false           # Fecha de encuesta
      t.string :zona, limit: 60                    # Zona
      t.string :fundempresa, limit: 10, unique: true # Código único (UK_FORMULARIO)
      t.integer :numero_comercio, null: false       # Número de comercio
      t.string :calle_numero, limit: 200, null: false # Dirección
      t.string :planta, limit: 30                  # Planta
      t.string :numero_local, limit: 13            # Número local
      t.string :telefono1, limit: 50               # Teléfono 1
      t.string :telefono2, limit: 50               # Teléfono 2
      t.string :telefono3, limit: 50               # Teléfono 3
      t.string :horario, limit: 100                # Horario
      t.string :observacion, limit: 200            # Observación
      t.string :empresa, limit: 200                # Empresa
      t.string :observacion2, limit: 200           # Observación 2
      t.string :email, limit: 100                  # Email
      t.string :pagina_web, limit: 200             # Página web
      t.string :servicios, limit: 600              # Servicios
      t.string :ofertas, limit: 600                # Ofertas
      t.binary :logo                               # Logo (antes CLOB)
      t.string :contacto, limit: 100               # Contacto
      t.string :ocultas, limit: 500                # Ocultas
      t.boolean :bloqueado, null: false, default: false # Bloqueado
      t.boolean :activo, null: false, default: true     # Activo
      t.integer :seprec, null: true                # SEPREC
      t.integer :seprec_est, null: true            # SEPREC_EST
      t.string :nit, limit: 12                     # NIT

      t.timestamps
    end
  end
end
