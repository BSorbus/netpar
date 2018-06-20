class AddEsodCategoryToExam < ActiveRecord::Migration
  def up
    add_column :exams, :esod_category, :integer

    Exam.where(category: 'L').update_all(esod_category: 101)

    Exam.reset_column_information
    Exam.where(category: ['M', 'R']).all.each do |e|
      if e.examinations_count > 0
        e.update_attribute :esod_category, 47
      else
        e.update_attribute :esod_category, 101
      end
    end
  end

  def down
    remove_column :exams, :esod_category
  end

end
