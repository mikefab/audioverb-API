# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_18_015827) do

  create_table "acts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "user_name"
    t.integer "cap_id"
    t.integer "num"
    t.string "nam"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["nam"], name: "index_acts_on_nam"
    t.index ["user_id"], name: "index_acts_on_user_id"
  end

  create_table "caps", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "cap"
    t.integer "lng_id"
    t.integer "num"
    t.string "start"
    t.string "stop"
    t.integer "nam_id"
    t.integer "src_id"
    t.integer "wcount"
    t.integer "ccount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cap"], name: "index_caps_on_cap"
    t.index ["lng_id"], name: "index_caps_on_lng_id"
    t.index ["nam_id"], name: "index_caps_on_nam_id"
    t.index ["num"], name: "index_caps_on_num"
    t.index ["src_id"], name: "index_caps_on_src_id"
    t.index ["start"], name: "index_caps_on_start"
  end

  create_table "caps_clas", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "cap_id"
    t.integer "cla_id"
    t.index ["cap_id"], name: "index_caps_clas_on_cap_id"
    t.index ["cla_id"], name: "index_caps_clas_on_cla_id"
  end

  create_table "caps_vocs", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "cap_id"
    t.integer "voc_id"
    t.index ["cap_id"], name: "index_caps_vocs_on_cap_id"
    t.index ["voc_id"], name: "index_caps_vocs_on_voc_id"
  end

  create_table "clas", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "cla"
    t.integer "lng_id"
    t.integer "mood_id"
    t.integer "tense_id"
    t.integer "tiempo_id"
    t.integer "verb_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cla"], name: "index_clas_on_cla"
    t.index ["lng_id"], name: "index_clas_on_lng_id"
  end

  create_table "clas_lngs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "cla_id"
    t.integer "lng_id"
    t.integer "olng_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cla_id"], name: "index_clas_lngs_on_cla_id"
    t.index ["lng_id"], name: "index_clas_lngs_on_lng_id"
    t.index ["olng_id"], name: "index_clas_lngs_on_olng_id"
  end

  create_table "cons", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "con"
    t.integer "tense_id"
    t.integer "verb_id"
    t.integer "mood_id"
    t.integer "tiempo_id"
    t.integer "lng_id"
    t.integer "priority"
    t.string "pronoun"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["con"], name: "index_cons_on_con"
    t.index ["lng_id"], name: "index_cons_on_lng_id"
    t.index ["mood_id"], name: "index_cons_on_mood_id"
    t.index ["priority"], name: "index_cons_on_priority"
    t.index ["tense_id"], name: "index_cons_on_tense_id"
    t.index ["tiempo_id"], name: "index_cons_on_tiempo_id"
    t.index ["verb_id"], name: "index_cons_on_verb_id"
  end

  create_table "cuts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "num"
    t.string "start"
    t.string "stop"
    t.integer "cap_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cap_id"], name: "index_cuts_on_cap_id"
    t.index ["num"], name: "index_cuts_on_num"
    t.index ["start"], name: "index_cuts_on_start"
  end

  create_table "defs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "kanji_id"
    t.integer "entry_id"
    t.text "def"
    t.integer "voc_id"
    t.integer "rank"
    t.string "pos", limit: 10
    t.string "gram", limit: 10
    t.string "level", limit: 5
    t.index ["def"], name: "index_defs_on_def", length: 5
    t.index ["entry_id"], name: "index_defs_on_entry_id"
    t.index ["gram"], name: "index_defs_on_gram"
    t.index ["kanji_id"], name: "index_defs_on_kanji_id"
    t.index ["level"], name: "index_defs_on_level"
    t.index ["pos"], name: "index_defs_on_pos"
    t.index ["rank"], name: "index_defs_on_rank"
  end

  create_table "entries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "kanji_id"
    t.string "entry"
    t.index ["entry"], name: "index_entries_on_entry"
    t.index ["kanji_id"], name: "index_entries_on_kanji_id"
  end

  create_table "lasts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "num"
    t.string "kind"
    t.string "bench"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "lngs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "lng"
    t.string "cod"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "lngs_nams", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "lng_id"
    t.integer "nam_id"
    t.index ["lng_id"], name: "index_lngs_nams_on_lng_id"
    t.index ["nam_id"], name: "index_lngs_nams_on_nam_id"
  end

  create_table "lngs_vocs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "lng_id"
    t.integer "voc_id"
    t.integer "seen"
    t.integer "olng_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lng_id"], name: "index_lngs_vocs_on_lng_id"
    t.index ["olng_id"], name: "index_lngs_vocs_on_olng_id"
    t.index ["voc_id"], name: "index_lngs_vocs_on_voc_id"
  end

  create_table "moods", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "mood"
    t.integer "lng_id"
    t.integer "priority"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lng_id"], name: "index_moods_on_lng_id"
    t.index ["mood"], name: "index_moods_on_mood"
    t.index ["priority"], name: "index_moods_on_priority"
  end

  create_table "nams", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "nam"
    t.integer "lng_id"
    t.string "duration"
    t.integer "src_id"
    t.string "season"
    t.string "episode"
    t.string "upldr"
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "pad_start"
    t.string "pad_end"
    t.index ["episode"], name: "index_nams_on_episode"
    t.index ["lng_id"], name: "index_nams_on_lng_id"
    t.index ["nam"], name: "index_nams_on_nam"
    t.index ["season"], name: "index_nams_on_season"
    t.index ["src_id"], name: "index_nams_on_src_id"
    t.index ["title"], name: "index_nams_on_title"
    t.index ["upldr"], name: "index_nams_on_upldr"
  end

  create_table "nams_vocs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "nam_id"
    t.integer "voc_id"
    t.index ["nam_id"], name: "index_nams_vocs_on_nam_id"
    t.index ["voc_id"], name: "index_nams_vocs_on_voc_id"
  end

  create_table "srcs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "src"
    t.integer "lng_id"
    t.string "ser"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lng_id"], name: "index_srcs_on_lng_id"
    t.index ["ser"], name: "index_srcs_on_ser"
    t.index ["src"], name: "index_srcs_on_src"
  end

  create_table "subs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "sub"
    t.integer "cap_id"
    t.integer "lng_id"
    t.integer "num"
    t.string "start"
    t.string "stop"
    t.integer "nam_id"
    t.integer "src_id"
    t.integer "clng_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cap_id"], name: "index_subs_on_cap_id"
    t.index ["clng_id"], name: "index_subs_on_clng_id"
  end

  create_table "tenses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "tense"
    t.integer "mood_id"
    t.integer "tiempo_id"
    t.integer "lng_id"
    t.integer "priority"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lng_id"], name: "index_tenses_on_lng_id"
    t.index ["mood_id"], name: "index_tenses_on_mood_id"
    t.index ["priority"], name: "index_tenses_on_priority"
    t.index ["tense"], name: "index_tenses_on_tense"
    t.index ["tiempo_id"], name: "index_tenses_on_tiempo_id"
  end

  create_table "tiempos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "tiempo"
    t.integer "lng_id"
    t.integer "priority"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lng_id"], name: "index_tiempos_on_lng_id"
    t.index ["priority"], name: "index_tiempos_on_priority"
    t.index ["tiempo"], name: "index_tiempos_on_tiempo"
  end

  create_table "verbs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "verb"
    t.integer "lng_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lng_id"], name: "index_verbs_on_lng_id"
    t.index ["verb"], name: "index_verbs_on_verb"
  end

  create_table "vocs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "voc"
    t.float "freq"
    t.integer "gram"
    t.integer "lng_id"
    t.integer "rank"
    t.integer "raw"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
