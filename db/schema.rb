# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_01_10_163517) do
  create_table "ciudades", force: :cascade do |t|
    t.string "ciudad", null: false
    t.string "cod_municipio"
    t.string "pais"
    t.string "cod_pais"
    t.binary "imagen"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comercios", force: :cascade do |t|
    t.decimal "latitud", precision: 10, scale: 6
    t.decimal "longitud", precision: 10, scale: 6
    t.date "fecha_registro", null: false
    t.date "fecha_encuesta", null: false
    t.string "zona", limit: 60
    t.string "fundempresa", limit: 10
    t.integer "numero_comercio", precision: 38, null: false
    t.string "calle_numero", limit: 200, null: false
    t.string "planta", limit: 30
    t.string "numero_local", limit: 13
    t.string "telefono1", limit: 50
    t.string "telefono2", limit: 50
    t.string "telefono3", limit: 50
    t.string "horario", limit: 100
    t.string "observacion", limit: 200
    t.string "empresa", limit: 200
    t.string "observacion2", limit: 200
    t.string "email", limit: 100
    t.string "pagina_web", limit: 200
    t.string "servicios", limit: 600
    t.string "ofertas", limit: 600
    t.binary "logo"
    t.string "contacto", limit: 100
    t.string "ocultas", limit: 500
    t.boolean "bloqueado", default: false, null: false
    t.boolean "activo", default: true, null: false
    t.integer "seprec", precision: 38, null: false
    t.decimal "seprec_est", precision: 10, scale: 2, null: false
    t.string "nit", limit: 12
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ciudad_id", precision: 38, null: false
    t.index ["ciudad_id"], name: "index_comercios_on_ciudad_id"
  end

  create_table "impresiones", force: :cascade do |t|
    t.datetime "fecha", null: false
    t.string "ip", limit: 45, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comercio_id", precision: 38, null: false
    t.index ["comercio_id"], name: "index_impresiones_on_comercio_id"
  end

  create_table "log_clics", force: :cascade do |t|
    t.string "ip", limit: 45, null: false
    t.datetime "fecha", null: false
    t.string "fuente", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comercio_id", precision: 38, null: false
    t.index ["comercio_id"], name: "index_log_clics_on_comercio_id"
  end

  create_table "logs", force: :cascade do |t|
    t.string "texto", limit: 500
    t.integer "resultado", precision: 38, null: false
    t.string "ip", limit: 100, null: false
    t.datetime "fecha", null: false
    t.string "aux", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "zona_id", precision: 38
    t.integer "ciudad_id", precision: 38
    t.index ["ciudad_id"], name: "index_logs_on_ciudad_id"
    t.index ["zona_id"], name: "index_logs_on_zona_id"
  end

  create_table "padron", force: :cascade do |t|
    t.string "ciudadano", limit: 12
    t.string "tipocedulaact", limit: 1
    t.string "cedulaact", limit: 30
    t.string "appat", limit: 50
    t.string "apmat", limit: 50
    t.string "apesp", limit: 50
    t.string "nombres", limit: 100
    t.string "sexo", limit: 5
    t.string "estadocivil", limit: 3
    t.string "paisnac", limit: 30
    t.string "fechanac", limit: 19
    t.string "mesaciudadano", limit: 20
    t.string "partidamesaciudadano", limit: 20
    t.string "fechains", limit: 36
    t.string "dom1", limit: 100
    t.string "dom2", limit: 100
    t.string "idloc", limit: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "zonas", force: :cascade do |t|
    t.string "descripcion", limit: 50, null: false
    t.integer "total", precision: 38, default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ciudad_id", precision: 38, null: false
    t.index ["ciudad_id"], name: "index_zonas_on_ciudad_id"
  end

  add_foreign_key "comercios", "ciudades", column: "ciudad_id"
  add_foreign_key "impresiones", "comercios"
  add_foreign_key "log_clics", "comercios"
  add_foreign_key "logs", "ciudades", column: "ciudad_id"
  add_foreign_key "logs", "zonas"
  add_foreign_key "zonas", "ciudades", column: "ciudad_id"
end
