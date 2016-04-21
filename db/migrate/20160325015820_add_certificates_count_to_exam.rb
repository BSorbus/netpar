class AddCertificatesCountToExam < ActiveRecord::Migration
  def up
    add_column :exams, :certificates_count, :integer, default: 0

#    Exam.reset_column_information
#    Exam.all.each do |e|
#      e.update_attribute :certificates_count, e.certificates.length
#    end
  end

  def down
    remove_column :exams, :certificates_count
  end

end
