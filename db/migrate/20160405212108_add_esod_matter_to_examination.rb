class AddEsodMatterToExamination < ActiveRecord::Migration
  def change
    add_reference :examinations, :esod_matter, index: true, foreign_key: true
  end
end
