class ExamsDivisionsSubject < ActiveRecord::Base
  belongs_to :exams_division
  belongs_to :subject

  # validates
  validates :subject, presence: true

  # validates :testportal_test_id, presence: true,
  #                   length: { in: 1..100 }

  # callbacks
  after_save :set_testportal_test_id, if: "(self.testportal_test_id.blank?) && (self.persisted?)"

  # after_destroy :destroy_testportal_test_after_destroy_eds, unless: "(self.testportal_test_id.blank?) && (self.persisted?)"
  # 2023-12-17
  before_destroy :destroy_testportal_test_after_destroy_eds, unless: "(self.testportal_test_id.blank?) && (self.persisted?)"

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
    api_call_correct, test_hash = ApiTestportalTest::test_info_in_testportal_where_test_id(self.testportal_test_id)
    # Test jest użyty w Netpar lecz usunięty z Testportal
    if api_call_correct
      if test_hash.blank?
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
          # jeżeli test jest, to od razu przypisz
          old_test_id = self.testportal_test_id
          if old_test_id != id_test
            self.update_columns(testportal_test_id: "#{id_test}")
            puts "info -> SET testportal_test_id: #{id_test} INTO ExamsDivionsSubject.id: #{self.id}"
            # odśwież klucze dostępu
            self.exams_division.exam.grades.where(subject_id: self.subject_id).each do |grade|
              grade.set_testportal_access_code_id(id_test: "#{id_test}", force_new_code: true)
            end
          end
        else
          # jezeli nie ma, to pobierz identyfikator wzorca
          template_id_test = "#{self.subject.test_template}"
          # duplikuj z wzorca nadajac stosowna nazwe
          name_test = self.full_netpar_test_name_for_testportal
          api_call_correct, id_test = ApiTestportalTest::duplicate_test_from_template(template_id_test, name_test)
          if api_call_correct
            self.update_columns(testportal_test_id: "#{id_test}")
            puts "info -> SET testportal_test_id: #{id_test} INTO ExamsDivionsSubject.id: #{self.id}"
            # odśwież klucze dostępu
            self.exams_division.exam.grades.where(subject_id: self.subject_id).each do |grade|
              grade.set_testportal_access_code_id(id_test: "#{id_test}", force_new_code: true)
            end
          end
        end
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

  def testportal_test_activate
    item_obj = ApiTestportalTest.new(id_test: self.testportal_test_id)
    if item_obj.request_for_activate
      puts "info -> testportal_test_id: #{self.testportal_test_id} ACTIVATED"
    end
  end

  def clean_testportal_test_id
    item_obj = ApiTestportalTest.new(id_test: self.testportal_test_id)
    if item_obj.request_for_destroy
      puts "info -> DESTROY testportal_test_id: #{self.testportal_test_id}"
      self.update_columns(testportal_test_id: "")
    end
  end

  def download_results_pdfs_from_testportal_and_save
    data_to_saved_array = ApiTestportalTest.get_identifiers_headers_sheets_by_test_id(self.testportal_test_id)
    data_to_saved_array.each do |to_save|
      file_name = "#{to_save[:name_test].gsub('/','_')} - #{to_save[:nazwisko]} #{to_save[:imie]}.pdf"
      grade = Grade.find_by(testportal_access_code_id: "#{to_save[:testportal_access_code_id]}")
      examination = grade.examination

      item_obj = ApiTestportalTest.new(id_test: "#{to_save[:id_test]}", id_attempt: "#{to_save[:id_attempt]}")

      api_call_correct = item_obj.request_for_one_sheets_pdf
      if api_call_correct
        refile_document = examination.documents.create( fileattach: StringIO.new(item_obj.response.body),
                                                        fileattach_filename: "#{file_name}",
                                                        fileattach_content_type: "application/pdf" )
      end
    end
    return data_to_saved_array.size
  end

  private

end
