class AddProposalsCountToExam < ActiveRecord::Migration
  def up
    add_column :exams, :proposals_count, :integer, default: 0

#    Exam.reset_column_information
#    Exam.all.each do |e|
#      e.update_attribute :examinations_count, e.examinations.length
#    end
  end

  def down
    remove_column :exams, :proposals_count
  end

end
