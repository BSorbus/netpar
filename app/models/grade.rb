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
  # nie usuwamy wygenerowanych kluczy
  # after_destroy :destroy_testportal_access_code_after_destroy_grade, unless: "(self.set_testportal_access_code_id.blank?) && (self.persisted?)"


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

  def set_testportal_access_code_id(params = {})
    if self.examination.exam.online?
      # Nie sprawdzamy czy jest test o takiej nazwie i takiej kategorii, gdyż nie jest możliwe dodawanie examinations, gdy nie ma 
      # odszukaj właściwy identyfikator testu jeżeli nie został podany w parametrze
      id_test = params.fetch(:id_test, 
                ExamsDivisionsSubject.joins(:exams_division, exams_division: [:exam]).
                  where(subject_id: self.subject.id, 
                        exams_divisions: {division_id: self.examination.division_id},
                        exams: {id: self.examination.exam.id}).first.testportal_test_id)

      force_new_code = params.fetch(:force_new_code, false)

      if self.testportal_access_code_id.blank? || force_new_code
        api_call_correct, access_code_hash = ApiTestportalAccessCode::access_code_add_to_test("#{id_test}")
        if api_call_correct
          access_code = ""
          if access_code_hash["accessCodes"].present? 
            if access_code_hash["accessCodes"].first.present?
              if access_code_hash["accessCodes"].first["accessCode"].present?            
                access_code = access_code_hash["accessCodes"].first["accessCode"] 
              end
            end
          end
          unless access_code.blank?
            # jeżeli jest, to od razu przypisz
            self.update_columns(testportal_access_code_id: "#{access_code}")
            puts "info -> SET testportal_access_code_id: #{id_test} INTO Grade.id: #{self.id}"
          end
        end
      end
    end
  end
  
end
