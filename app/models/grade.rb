class Grade < ActiveRecord::Base
  belongs_to :examination
  belongs_to :subject
  belongs_to :user

  # validates
  validates :examination, presence: true
  validates :subject, presence: true
  validates :user, presence: true
  validates :grade_result, inclusion: { in: ["", nil, "N", "P"] }

  # callbacks
  after_save :set_testportal_access_code_id, if: "(self.set_testportal_access_code_id.blank?) && (self.persisted?)"
  after_destroy :destroy_testportal_access_code_after_destroy_grade, unless: "(self.set_testportal_access_code_id.blank?) && (self.persisted?)"


  def grade_result_name
    case grade_result
    when '', nil
      ''
    when 'N'
      'Negatywna'
    when 'P'
      'Pozytywna'
    else
      'Error grade_result value !'
    end  
  end

  def set_testportal_access_code_id
    if self.examination.exam.online?
      set_testportal_access_code_id = "#{Time.now.strftime('%Y-%m-%d %H:%M:%S:%N')}"
      puts '----------------------------------------------------------'
      puts "info -> SET set_testportal_access_code_id: #{set_testportal_access_code_id} INTO Grade.id: #{self.id}"
      puts '----------------------------------------------------------'
      self.update_columns(testportal_access_code_id: "#{set_testportal_access_code_id}")
      
    #   # sprawdz czy jest test o takiej nazwie i takiej kategorii 
    #   api_call_correct, id_test = ApiTestportalTest::test_id_in_testportal_where_category_and_name(self.full_netpar_test_name_for_testportal, self.full_netpar_category_name_for_testportal)
    #   if api_call_correct
    #     unless id_test.blank?
    #       # jeżeli jest, to od razu przypisz
    #       self.update_columns(testportal_test_id: "#{id_test}")
    #     else
    #       # jezeli nie ma, to pobierz identyfikator wzorca
    #       template_id_test = "#{self.subject.test_template}"
    #       # duplikuj z wzorca nadajac stosowna nazwe
    #       name_test = self.full_netpar_test_name_for_testportal
    #       api_call_correct, id_test = ApiTestportalTest::duplicate_test_from_template(template_id_test, name_test)
    #       self.update_columns(testportal_test_id: "#{id_test}")
    #     end
    #     puts "info -> SET testportal_test_id: #{id_test} INTO ExamsDivionsSubject.id: #{self.id}"
    #   else
    #     puts "info -> NO SET testportal_test_id because API ERROR(s)"
    #   end
    end
  end
  
  def destroy_testportal_test_after_destroy_eds
    # item_obj = ApiTestportalAccessCode.new(id_test: self.examination.exam.exams_divisions_subjects.find_by(subject: self.subject, division: self.division))
    # if item_obj.request_for_destroy
       puts "info -> DESTROY set_testportal_access_code_id: #{self.set_testportal_access_code_id} because Grade.id: #{self.id} destroyed"
    # end
  end

  def clean_testportal_test_id
    # item_obj = ApiTestportalTest.new(id_test: self.testportal_test_id)
    # if item_obj.request_for_destroy
    #   puts "info -> DESTROY testportal_test_id: #{self.testportal_test_id} because Exam is not Online"
    #   self.update_columns(testportal_test_id: "")
    # end
  end

end
