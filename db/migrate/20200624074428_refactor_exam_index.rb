class RefactorExamIndex < ActiveRecord::Migration
  def up
  # add_index "exams", ["category"], name: "index_exams_on_category", using: :btree
  # add_index "exams", ["date_exam"], name: "index_exams_on_date_exam", using: :btree
  # add_index "exams", ["number", "category"], name: "index_exams_on_number_and_category", unique: true, using: :btree
  # add_index "exams", ["user_id"], name: "index_exams_on_user_id", using: :btree

    add_index  :exams, :number,         name: "exams_number_idx",           using: :gin, order: {number: :gin_trgm_ops}
    add_index  :exams, :place_exam,     name: "exams_place_exam_idx",       using: :gin, order: {place_exam: :gin_trgm_ops}
    add_index  :exams, :province_name,  name: "exams_province_name_idx",    using: :gin, order: {province_name: :gin_trgm_ops}
    add_index  :exams, :info,           name: "exams_info_idx",             using: :gin, order: {info: :gin_trgm_ops}
  end

  def down
    remove_index :exams, name: "exams_number_idx"
    remove_index :exams, name: "exams_place_exam_idx"
    remove_index :exams, name: "exams_province_name_idx"
    remove_index :exams, name: "exams_info_idx"

    # add_index :teryt_pna_codes, :pna_teryt #, unique: true
    # add_index :teryt_pna_codes, [:mie_nazwa, :uli_nazwa, :pna]
  end
end
