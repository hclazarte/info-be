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

ActiveRecord::Schema[7.0].define(version: 2025_01_15_175516) do
  create_table "ciudades", force: :cascade do |t|
    t.string "ciudad", null: false
    t.string "cod_municipio"
    t.string "pais"
    t.string "cod_pais"
    t.binary "imagen"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

# Could not dump table "comercios" because of following StandardError
#   Unknown type 'MDSYS.SDO_GEOMETRY' for column 'shape'

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
    t.string "pad_descr", limit: 4000

  end

  add_context_index "padron", ["pad_descr"], name: "textindex_pad"

  create_table "zonas", force: :cascade do |t|
    t.string "descripcion", limit: 50, null: false
    t.integer "total", precision: 38, default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ciudad_id", precision: 38, null: false
    t.index ["ciudad_id"], name: "index_zonas_on_ciudad_id"
  end

  add_foreign_key "comercios", "ciudades", column: "ciudad_id"
  add_foreign_key "comercios", "zonas"
  add_foreign_key "impresiones", "comercios"
  add_foreign_key "log_clics", "comercios"
  add_foreign_key "logs", "ciudades", column: "ciudad_id"
  add_foreign_key "logs", "zonas"
  add_foreign_key "zonas", "ciudades", column: "ciudad_id"
end
