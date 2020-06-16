class RenameProposalDateExam < ActiveRecord::Migration
  def change
	rename_column :proposals, :date_exam, :exam_date_exam
  end
end
