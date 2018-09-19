# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_09_18_074518) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "affiliations", force: :cascade do |t|
    t.integer "collection_id", null: false
    t.integer "feature_id", null: false
    t.integer "perspective_id"
    t.boolean "descendants", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["collection_id", "feature_id", "perspective_id"], name: "affiliations_on_dependencies", unique: true
  end

  create_table "authors_descriptions", id: false, force: :cascade do |t|
    t.integer "description_id", null: false
    t.integer "author_id", null: false
  end

  create_table "authors_notes", id: false, force: :cascade do |t|
    t.integer "note_id", null: false
    t.integer "author_id", null: false
  end

  create_table "blurbs", force: :cascade do |t|
    t.string "code"
    t.string "title"
    t.text "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cached_feature_names", force: :cascade do |t|
    t.integer "feature_id", null: false
    t.integer "view_id", null: false
    t.integer "feature_name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["feature_id", "view_id"], name: "index_cached_feature_names_on_feature_id_and_view_id", unique: true
  end

  create_table "captions", force: :cascade do |t|
    t.integer "language_id", null: false
    t.text "content", null: false
    t.integer "author_id", null: false
    t.integer "feature_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "citations", force: :cascade do |t|
    t.integer "info_source_id", null: false
    t.string "citable_type", null: false
    t.integer "citable_id", null: false
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "info_source_type", null: false
    t.index ["citable_id", "citable_type"], name: "citations_1_idx"
    t.index ["info_source_id"], name: "citations_info_source_id_idx"
  end

  create_table "collections_users", id: false, force: :cascade do |t|
    t.integer "collection_id", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "collection_id"], name: "index_collections_users_on_user_id_and_collection_id", unique: true
  end

  create_table "complex_dates", force: :cascade do |t|
    t.integer "year"
    t.integer "year_certainty_id"
    t.integer "season_id"
    t.integer "season_certainty_id"
    t.integer "month"
    t.integer "month_certainty_id"
    t.integer "day"
    t.integer "day_certainty_id"
    t.integer "day_of_week_id"
    t.integer "day_of_week_certainty_id"
    t.integer "time_of_day_id"
    t.integer "time_of_day_certainty_id"
    t.integer "hour"
    t.integer "hour_certainty_id"
    t.integer "minute"
    t.integer "minute_certainty_id"
    t.integer "animal_id"
    t.integer "animal_certainty_id"
    t.integer "calendrical_id"
    t.integer "calendrical_certainty_id"
    t.integer "element_certainty_id"
    t.integer "element_id"
    t.integer "gender_id"
    t.integer "gender_certainty_id"
    t.integer "intercalary_month_id"
    t.integer "intercalary_day_id"
    t.integer "rabjung_id"
    t.integer "rabjung_certainty_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "year_end"
    t.integer "season_end_id"
    t.integer "month_end"
    t.integer "day_end"
    t.integer "day_of_week_end_id"
    t.integer "time_of_day_end_id"
    t.integer "hour_end"
    t.integer "minute_end"
    t.integer "rabjung_end_id"
    t.integer "intercalary_month_end_id"
    t.integer "intercalary_day_end_id"
  end

  create_table "definition_relations", force: :cascade do |t|
    t.integer "child_node_id", null: false
    t.integer "parent_node_id", null: false
    t.string "ancestor_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "definition_subject_associations", force: :cascade do |t|
    t.bigint "definition_id", null: false
    t.integer "subject_id", null: false
    t.integer "branch_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["definition_id"], name: "index_definition_subject_associations_on_definition_id"
  end

  create_table "definitions", force: :cascade do |t|
    t.integer "feature_id", null: false
    t.integer "language_id", null: false
    t.boolean "is_public", default: false, null: false
    t.boolean "is_primary"
    t.string "ancestor_ids"
    t.integer "position", default: 0
    t.text "content", null: false
    t.integer "author_id"
    t.integer "numerology"
    t.string "tense"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "descriptions", force: :cascade do |t|
    t.integer "feature_id", null: false
    t.text "content", null: false
    t.boolean "is_primary", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title"
    t.string "source_url"
    t.integer "language_id", null: false
  end

  create_table "etymologies", force: :cascade do |t|
    t.integer "context_id"
    t.string "context_type"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "etymology_subject_associations", force: :cascade do |t|
    t.bigint "etymology_id", null: false
    t.integer "subject_id", null: false
    t.integer "branch_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["etymology_id"], name: "index_etymology_subject_associations_on_etymology_id"
  end

  create_table "etymology_type_associations", force: :cascade do |t|
    t.bigint "etymology_id", null: false
    t.integer "subject_id"
    t.integer "branch_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["etymology_id"], name: "index_etymology_type_associations_on_etymology_id"
  end

  create_table "external_pictures", force: :cascade do |t|
    t.string "url", null: false
    t.text "caption"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "place_id"
  end

  create_table "feature_geo_codes", force: :cascade do |t|
    t.integer "feature_id", null: false
    t.integer "geo_code_type_id", null: false
    t.integer "timespan_id"
    t.string "geo_code_value", null: false
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feature_name_relations", force: :cascade do |t|
    t.integer "child_node_id", null: false
    t.integer "parent_node_id", null: false
    t.string "ancestor_ids"
    t.integer "is_phonetic", limit: 2
    t.integer "is_orthographic", limit: 2
    t.integer "is_translation", limit: 2
    t.integer "is_alt_spelling", limit: 2
    t.integer "phonetic_system_id"
    t.integer "orthographic_system_id"
    t.integer "alt_spelling_system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["child_node_id"], name: "feature_name_relations_child_node_id_idx"
    t.index ["parent_node_id"], name: "feature_name_relations_parent_node_id_idx"
  end

  create_table "feature_names", force: :cascade do |t|
    t.integer "feature_id", null: false
    t.string "name", null: false
    t.integer "feature_name_type_id"
    t.string "ancestor_ids"
    t.integer "position", default: 0
    t.text "etymology"
    t.integer "writing_system_id"
    t.integer "language_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_primary_for_romanization", default: false
    t.index ["ancestor_ids"], name: "feature_names_ancestor_ids_idx"
    t.index ["feature_id"], name: "feature_names_feature_id_idx"
    t.index ["name"], name: "feature_names_name_idx"
  end

  create_table "feature_relation_types", force: :cascade do |t|
    t.boolean "is_symmetric"
    t.string "label", null: false
    t.string "asymmetric_label"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", null: false
    t.boolean "is_hierarchical", default: false, null: false
    t.string "asymmetric_code"
  end

  create_table "feature_relations", force: :cascade do |t|
    t.integer "child_node_id", null: false
    t.integer "parent_node_id", null: false
    t.string "ancestor_ids"
    t.text "notes"
    t.string "role", limit: 20
    t.integer "perspective_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "feature_relation_type_id", null: false
    t.index ["ancestor_ids"], name: "feature_relations_ancestor_ids_idx"
    t.index ["child_node_id"], name: "feature_relations_child_node_id_idx"
    t.index ["parent_node_id"], name: "feature_relations_parent_node_id_idx"
    t.index ["perspective_id"], name: "feature_relations_perspective_id_idx"
    t.index ["role"], name: "feature_relations_role_idx"
  end

  create_table "features", force: :cascade do |t|
    t.integer "is_public", limit: 2
    t.integer "position", default: 0
    t.string "ancestor_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "old_pid"
    t.boolean "is_blank", default: false, null: false
    t.integer "fid", null: false
    t.boolean "is_name_position_overriden", default: false, null: false
    t.index ["ancestor_ids"], name: "features_ancestor_ids_idx"
    t.index ["fid"], name: "features_fid", unique: true
    t.index ["is_public"], name: "features_is_public_idx"
  end

  create_table "illustrations", force: :cascade do |t|
    t.integer "feature_id", null: false
    t.integer "picture_id", null: false
    t.string "picture_type", null: false
    t.boolean "is_primary", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "importation_tasks", force: :cascade do |t|
    t.string "task_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "imported_spreadsheets", force: :cascade do |t|
    t.string "filename", null: false
    t.integer "task_id", null: false
    t.datetime "imported_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "imports", force: :cascade do |t|
    t.integer "spreadsheet_id", null: false
    t.integer "item_id", null: false
    t.string "item_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "info_sources", force: :cascade do |t|
    t.string "code", null: false
    t.string "title"
    t.string "agent"
    t.date "date_published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "info_sources_code_key", unique: true
  end

  create_table "model_sentences", force: :cascade do |t|
    t.integer "context_id"
    t.string "context_type"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "note_titles", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes", force: :cascade do |t|
    t.string "notable_type", null: false
    t.integer "notable_id", null: false
    t.integer "note_title_id"
    t.string "custom_note_title"
    t.text "content", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "association_type"
    t.boolean "is_public", default: true
  end

  create_table "pages", force: :cascade do |t|
    t.integer "citation_id", null: false
    t.integer "volume"
    t.integer "start_page"
    t.integer "start_line"
    t.integer "end_page"
    t.integer "end_line"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "passages", force: :cascade do |t|
    t.integer "context_id"
    t.string "context_type"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people", force: :cascade do |t|
    t.string "fullname", null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.string "title", limit: 60, null: false
    t.text "description"
    t.index ["title"], name: "index_permissions_on_title", unique: true
  end

  create_table "permissions_roles", id: false, force: :cascade do |t|
    t.integer "permission_id", null: false
    t.integer "role_id", null: false
    t.index ["permission_id", "role_id"], name: "index_permissions_roles_on_permission_id_and_role_id", unique: true
  end

  create_table "perspectives", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.text "description"
    t.text "notes"
    t.boolean "is_public", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_perspectives_on_code"
  end

  create_table "recordings", force: :cascade do |t|
    t.bigint "feature_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "dialect_id"
    t.index ["feature_id"], name: "index_recordings_on_feature_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "title", limit: 20, null: false
    t.text "description"
    t.index ["title"], name: "index_roles_on_title", unique: true
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "role_id", null: false
    t.integer "user_id", null: false
    t.index ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id", unique: true
  end

  create_table "simple_props", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.text "description"
    t.text "notes"
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "simple_props_code_idx"
    t.index ["type"], name: "simple_props_type_idx"
  end

  create_table "subject_term_associations", force: :cascade do |t|
    t.integer "feature_id", null: false
    t.integer "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "branch_id", null: false
  end

  create_table "summaries", force: :cascade do |t|
    t.integer "language_id", null: false
    t.text "content", null: false
    t.integer "author_id", null: false
    t.integer "feature_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "time_units", force: :cascade do |t|
    t.integer "date_id"
    t.integer "start_date_id"
    t.integer "end_date_id"
    t.integer "calendar_id"
    t.boolean "is_range"
    t.integer "dateable_id"
    t.string "dateable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "frequency_id"
  end

  create_table "timespans", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.integer "start_date_fuzz"
    t.integer "end_date_fuzz"
    t.integer "is_current", limit: 2
    t.integer "dateable_id", null: false
    t.string "dateable_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["dateable_id", "dateable_type"], name: "timespans_1_idx"
    t.index ["end_date"], name: "timespans_end_date_idx"
    t.index ["start_date"], name: "timespans_start_date_idx"
  end

  create_table "users", force: :cascade do |t|
    t.string "login", null: false
    t.string "email", null: false
    t.integer "person_id", null: false
    t.string "crypted_password", limit: 40
    t.string "salt", limit: 40
    t.string "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "identity_url"
    t.string "shibboleth_id"
  end

  create_table "web_pages", force: :cascade do |t|
    t.string "path", null: false
    t.string "title", null: false
    t.integer "citation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "xml_documents", force: :cascade do |t|
    t.integer "feature_id", null: false
    t.text "document", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["feature_id"], name: "xml_documents_feature_id_idx"
  end

  add_foreign_key "definition_subject_associations", "definitions"
  add_foreign_key "etymology_subject_associations", "etymologies"
  add_foreign_key "etymology_type_associations", "etymologies"
  add_foreign_key "recordings", "features"
end
