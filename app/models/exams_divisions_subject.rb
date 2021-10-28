class ExamsDivisionsSubject < ActiveRecord::Base
  belongs_to :exams_division
  belongs_to :subject

  # validates
  validates :subject, presence: true

  # validates :testportal_test_id, presence: true,
  #                   length: { in: 1..100 }

  # callbacks
  # after_initialize :set_testportal_test_id, if: "self.new_record?"


  def colorized_testportal_id
    testportal_test_id.empty? ? 
    "<span class='pull-right'> [ <span class='text-danger'>Brak testu w TestPortalu</span> ] </span>" : 
    "<span class='pull-right'> [ <span class='text-success'>#{testportal_test_id}</span> ] </span>"
  end

  def set_testportal_test_id
    self.testportal_test_id = "#{Time.now.strftime('%Y-%m-%d %H:%M:%S:%N')}"
  end
  
  def clean_testportal_test_id
    self.testportal_test_id = "#{Time.now.strftime('%Y-%m-%d %H:%M:%S:%N')}"
  end
  
end
