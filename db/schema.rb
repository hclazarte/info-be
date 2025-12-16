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

ActiveRecord::Schema[7.0].define(version: 2025_12_16_202140) do
  create_table "campania_propietarios_emails", force: :cascade do |t|
    t.integer "comercio_id", limit: 19, precision: 19, null: false
    t.string "email", null: false
    t.boolean "enviado", default: false, null: false
    t.boolean "clic", default: false, null: false
    t.integer "intentos_envio", precision: 38, default: 0, null: false
    t.datetime "ultima_fecha_envio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "email_rebotado", precision: 38, default: 0, null: false
    t.boolean "es_tramitador", default: false, null: false
    t.index ["comercio_id"], name: "index_campania_propietarios_emails_on_comercio_id", unique: true
  end

  create_table "ciudades", force: :cascade do |t|
    t.string "ciudad", null: false
    t.string "cod_municipio"
    t.string "pais"
    t.string "cod_pais"
    t.binary "imagen"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total", precision: 38, default: 0, null: false
    t.index ["ciudad"], name: "index_ciudades_on_ciudad"
  end

  create_table "comercios", force: :cascade do |t|
    t.decimal "latitud", precision: 10, scale: 6
    t.decimal "longitud", precision: 10, scale: 6
    t.date "fecha_registro", null: false
    t.date "fecha_encuesta", null: false
    t.string "zona_nombre", limit: 60
    t.string "fundempresa", limit: 10
    t.integer "numero_comercio", precision: 38
    t.string "calle_numero", limit: 200, null: false
    t.string "planta", limit: 30
    t.string "numero_local", limit: 20
    t.string "telefono1", limit: 50
    t.string "telefono2", limit: 50
    t.string "telefono_whatsapp", limit: 50
    t.string "horario", limit: 100
    t.string "observacion", limit: 200
    t.string "empresa", limit: 200, null: false
    t.string "observacion2", limit: 200
    t.string "email", limit: 100
    t.string "pagina_web", limit: 200
    t.string "servicios", limit: 600
    t.string "ofertas", limit: 600
    t.binary "logo"
    t.string "contacto", limit: 100
    t.string "palabras_clave", limit: 2000
    t.boolean "bloqueado", default: false, null: false
    t.boolean "activo", default: true, null: false
    t.integer "seprec", precision: 38
    t.integer "seprec_est", precision: 38
    t.string "nit", limit: 12
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ciudad_id", precision: 38, null: false
    t.string "com_descr", limit: 4000
    t.integer "zona_id", precision: 38
    t.integer "autorizado", precision: 38, default: 0, null: false
    t.integer "persona_natural", precision: 38, default: 0, null: false
    t.integer "documentos_validados", precision: 38, default: 0, null: false
    t.string "email_verificado"
    t.integer "campania_iniciada", precision: 38, default: 0, null: false
    t.boolean "whatsapp_verificado", default: true, null: false
    t.datetime "whatsapp_fecha_autorizado"
    t.text "wizard_payload"
    t.string "tipo_unidad_economica"
    t.index ["\"AUTORIZADO\"", "\"ID\""], name: "idx_comercios_autorizado_id"
    t.index ["ciudad_id"], name: "index_comercios_on_ciudad_id"
  end

  add_context_index "comercios", ["com_descr"], name: "textindex_com"

# Could not dump table "comercios_shape" because of following StandardError
#   Unknown type 'PUBLIC.SDO_GEOMETRY' for column 'shape'

  create_table "correos", force: :cascade do |t|
    t.string "remitente", null: false
    t.string "asunto", null: false
    t.integer "tipo", precision: 38, null: false
    t.text "cuerpo", null: false
    t.integer "estado", precision: 38, default: 0
    t.integer "intentos", precision: 38, default: 0
    t.datetime "fecha"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nombre"
  end

  create_table "correos_usuarios", force: :cascade do |t|
    t.string "remitente", null: false
    t.string "destinatario", null: false
    t.string "asunto", null: false
    t.text "cuerpo", null: false
    t.integer "estado", precision: 38, default: 0, null: false
    t.integer "intentos", precision: 38, default: 0, null: false
    t.datetime "fecha"
    t.string "nombre"
    t.integer "comercio_id", precision: 38
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "numero_celular"
    t.index ["comercio_id"], name: "index_correos_usuarios_on_comercio_id"
  end

  create_table "emails_bloqueados", force: :cascade do |t|
    t.string "email", null: false
    t.text "motivo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_emails_bloqueados_on_email", unique: true
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comercio_id", precision: 38, null: false
    t.integer "plataforma", precision: 38, default: 0, null: false
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

  create_table "promotores", force: :cascade do |t|
    t.string "nombre", null: false
    t.string "email", null: false
    t.string "telefono", null: false
    t.integer "estado", precision: 38, default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_promotores_on_email", unique: true
  end

  create_table "solicitudes", force: :cascade do |t|
    t.string "email", null: false
    t.integer "comercio_id", precision: 38
    t.binary "nit_imagen"
    t.binary "ci_imagen"
    t.boolean "nit_ok", default: false
    t.boolean "ci_ok", default: false
    t.string "nombre"
    t.integer "estado", precision: 38, default: 0
    t.string "otp_token"
    t.datetime "otp_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.binary "comprobante_imagen"
    t.datetime "fecha_fin_servicio"
    t.integer "email_rebotado", precision: 38, default: 0
    t.integer "intentos", precision: 38, default: 0
    t.index ["comercio_id"], name: "index_solicitudes_on_comercio_id"
    t.index ["email", "comercio_id"], name: "index_solicitudes_on_email_and_comercio_id_unique", unique: true
  end

  create_table "usuarios_whatsapp", force: :cascade do |t|
    t.string "celular", null: false
    t.string "nombre"
    t.boolean "whatsapp_verificado", default: false
    t.datetime "whatsapp_fecha_autorizado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["celular"], name: "index_usuarios_whatsapp_on_celular", unique: true
  end

  create_table "vales", force: :cascade do |t|
    t.string "codigo", null: false
    t.integer "comercio_id", precision: 38
    t.boolean "usado", default: false, null: false
    t.datetime "usado_en"
    t.datetime "fecha_vencimiento", null: false
    t.string "motivo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["codigo"], name: "index_vales_on_codigo", unique: true
    t.index ["comercio_id"], name: "index_vales_on_comercio_id"
  end

  create_table "whatsapp_chats", force: :cascade do |t|
    t.integer "comercio_id", precision: 38
    t.string "nombre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "usuario_whatsapp_id", precision: 38
    t.text "mensaje"
    t.integer "estado", precision: 38
    t.index ["comercio_id"], name: "index_whatsapp_chats_on_comercio_id"
    t.index ["usuario_whatsapp_id"], name: "index_whatsapp_chats_on_usuario_whatsapp_id"
  end

  create_table "zonas", force: :cascade do |t|
    t.string "descripcion", limit: 50, null: false
    t.integer "total", precision: 38, default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ciudad_id", precision: 38, null: false
    t.index ["ciudad_id"], name: "index_zonas_on_ciudad_id"
    t.index ["descripcion"], name: "index_zonas_on_descripcion"
  end

# Could not dump table "zonas_shape" because of following StandardError
#   Unknown type 'PUBLIC.SDO_GEOMETRY' for column 'shape'

  add_foreign_key "comercios", "ciudades", column: "ciudad_id"
  add_foreign_key "comercios", "zonas"
  add_foreign_key "comercios_shape", "comercios", column: "id", name: "fk_comercios_shape", on_delete: :cascade
  add_foreign_key "correos_usuarios", "comercios"
  add_foreign_key "impresiones", "comercios"
  add_foreign_key "log_clics", "comercios"
  add_foreign_key "logs", "ciudades", column: "ciudad_id"
  add_foreign_key "logs", "zonas"
  add_foreign_key "solicitudes", "comercios"
  add_foreign_key "vales", "comercios"
  add_foreign_key "whatsapp_chats", "comercios"
  add_foreign_key "zonas", "ciudades", column: "ciudad_id"
  add_foreign_key "zonas_shape", "zonas", column: "id", name: "fk_zonas_shape", on_delete: :cascade
end
