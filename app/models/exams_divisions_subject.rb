class ExamsDivisionsSubject < ActiveRecord::Base
  belongs_to :exams_division
  belongs_to :subject

  # validates
  validates :subject, presence: true

  # validates :testportal_test_id, presence: true,
  #                   length: { in: 1..100 }

  # callbacks
  after_save :set_testportal_test_id, if: "(self.testportal_test_id.blank?) && (self.persisted?)"
  after_destroy :destroy_testportal_test_after_destroy_eds, unless: "(self.testportal_test_id.blank?) && (self.persisted?)"

  def colorized_testportal_id
    testportal_test_id.empty? ? 
    "<span class='pull-right'> [ <span class='text-danger'>Brak identyfikatora testu z TestPortal</span> ] </span>" : 
    "<span class='pull-right'> [ <span class='text-success'>#{testportal_test_id}</span> ] </span>"
  end

  def full_netpar_test_name_for_testportal
    "#{self.exams_division.exam.number}___#{self.subject.item}. #{self.subject.name}"
  end

  def full_netpar_category_name_for_testportal
    "#{self.exams_division.exam.category}_#{self.exams_division.division.short_name}_#{self.subject.id}"
  end

  def check_and_recreate_testportal_test_id
    api_call_correct, id_test = ApiTestportalTest::check_exist_test_in_testportal(self.testportal_test_id)
    # Test jest użyty w Netpar lecz usunięty z Testportal
    if api_call_correct
      if id_test.blank?
        self.set_testportal_test_id
      end    
    end    
  end

  def set_testportal_test_id
    if self.exams_division.exam.online?
      # sprawdz czy jest test o takiej nazwie i takiej kategorii 
      api_call_correct, id_test = ApiTestportalTest::test_id_in_testportal_where_category_and_name(self.full_netpar_test_name_for_testportal, self.full_netpar_category_name_for_testportal)
      if api_call_correct
        unless id_test.blank?
          # jeżeli jest, to od razu przypisz
          self.update_columns(testportal_test_id: "#{id_test}")
        else
          # jezeli nie ma, to pobierz identyfikator wzorca
          template_id_test = "#{self.subject.test_template}"
          # duplikuj z wzorca nadajac stosowna nazwe
          name_test = self.full_netpar_test_name_for_testportal
          api_call_correct, id_test = ApiTestportalTest::duplicate_test_from_template(template_id_test, name_test)
          self.update_columns(testportal_test_id: "#{id_test}")
        end
        puts "info -> SET testportal_test_id: #{id_test} INTO ExamsDivionsSubject.id: #{self.id}"
      else
        puts "info -> NO SET testportal_test_id because API ERROR(s)"
      end
    end
  end
  
  def destroy_testportal_test_after_destroy_eds
    item_obj = ApiTestportalTest.new(id_test: self.testportal_test_id)
    if item_obj.request_for_destroy
      puts "info -> DESTROY testportal_test_id: #{self.testportal_test_id} because ExamsDivionsSubject.id: #{self.id} destroyed"
    end
  end

  def clean_testportal_test_id
    item_obj = ApiTestportalTest.new(id_test: self.testportal_test_id)
    if item_obj.request_for_destroy
      puts "info -> DESTROY testportal_test_id: #{self.testportal_test_id} because Exam is not Online"
      self.update_columns(testportal_test_id: "")
    end
  end

  private

end
