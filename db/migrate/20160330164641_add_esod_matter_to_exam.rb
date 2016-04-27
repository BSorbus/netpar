class AddEsodMatterToExam < ActiveRecord::Migration
  def change
    add_reference :exams, :esod_matter, index: true, foreign_key: true
  end
end
