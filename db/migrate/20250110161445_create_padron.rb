class CreatePadron < ActiveRecord::Migration[7.0]
  def change
    create_table :padron do |t|
      t.string :ciudadano, limit: 12          # Ciudadano
      t.string :tipocedulaact, limit: 1       # Tipo Cédula Actual
      t.string :cedulaact, limit: 30          # Cédula Actual
      t.string :appat, limit: 50              # Apellido Paterno
      t.string :apmat, limit: 50              # Apellido Materno
      t.string :apesp, limit: 50              # Apellido Esposo
      t.string :nombres, limit: 100           # Nombres
      t.string :sexo, limit: 5                # Sexo
      t.string :estadocivil, limit: 3         # Estado Civil
      t.string :paisnac, limit: 30            # País Nacimiento
      t.string :fechanac, limit: 19           # Fecha Nacimiento
      t.string :mesaciudadano, limit: 20      # Mesa Ciudadano
      t.string :partidamesaciudadano, limit: 20 # Partida Mesa Ciudadano
      t.string :fechains, limit: 36           # Fecha Inscripción
      t.string :dom1, limit: 100              # Domicilio 1
      t.string :dom2, limit: 100              # Domicilio 2
      t.string :idloc, limit: 4               # Localidad

      t.timestamps
    end
  end
end
