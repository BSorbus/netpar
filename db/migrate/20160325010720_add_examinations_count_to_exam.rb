class AddExaminationsCountToExam < ActiveRecord::Migration
  def up
    add_column :exams, :examinations_count, :integer, default: 0

    Exam.reset_column_information
    Exam.all.each do |e|
      e.update_attribute :examinations_count, e.examinations.length
    end
  end

  def down
    remove_column :exams, :examiniations_count
  end

end
