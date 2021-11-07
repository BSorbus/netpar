class ExamsDivisionsSubject < ActiveRecord::Base
  belongs_to :exams_division
  belongs_to :subject

  # validates
  validates :subject, presence: true

  # validates :testportal_test_id, presence: true,
  #                   length: { in: 1..100 }

  # callbacks
  after_save :set_testportal_test_id, if: "self.persisted?"
  after_destroy :clear_data_after_cos_tam

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

  def clear_data_after_cos_tam
    # if self.persisted?
    # else

    puts '----------------------------------------------------------------'
    puts "CALL ExamsDivisionsSubject: after_destroy :clear_data_after_cos_tam"
    puts "self.persisted?: #{self.persisted?}"
    puts "self.id: #{self.id}"
    puts "self.testportal_test_id.blank?: #{self.testportal_test_id.blank?}"
    puts '----------------------------------------------------------------'
  end

  def set_testportal_test_id
    if self.testportal_test_id.blank? && self.exams_division.exam.online?
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
  
  def set_access_code_testportal_test_id
    # sprawdz czy jest test o takich parametrach
    # jezeli jest, to pobierz pierwszy id!
    # jezeli nie ma, to dodaj nowy test
    # self.testportal_test_id = "#{Time.now.strftime('%Y-%m-%d %H:%M:%S:%N')}"
    self.update_columns(testportal_test_id: "#{Time.now.strftime('%Y-%m-%d %H:%M:%S:%N')}")
    #self.update_columns(testportal_test_id: id_testu_from_testportal)
    self.exams_division.exam.examinations.where(division: self.division).each do |examination|
      examination.grades.where(subject: examination.subject).each do |grade|
        #self.update_columns(testportal_test_id: id_testu_from_testportal)
      end

    end
    #
  end

  def clean_testportal_test_id
    # usun z testportalu test
    self.testportal_test_id = ""
  end

  private

end
