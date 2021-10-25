class ExamsDivision < ActiveRecord::Base
  belongs_to :exam
  belongs_to :division

  has_many :exams_divisions_subjects, dependent: :destroy
  has_many :subjects, through: :division

  accepts_nested_attributes_for :exams_divisions_subjects, reject_if: :all_blank, allow_destroy: true
  validates_associated :exams_divisions_subjects

	# scope :sort_by_subject_item, ->{
 #    joins(:subjects).order(Subject.arel_table[:item].asc)
 #  }

#  before_destroy :exams_division_has_links, prepend: true

  # validates
#  validate :all_generated_tests_valid, on: :create

  # callbacks
  after_initialize :build_testportal_tests_and_save_identifiers, if: "self.new_record?"


  # def flat_all_incoming_letters_matters
  def flat_all_exams_divisions_subjects
    self.exams_divisions_subjects.order(:id).flat_map {|row| "[#{row.subject.item}] #{row.subject.name} [#{row.testportal_test_id}]" }.join(' <br>').html_safe
  end

  def all_generated_tests_valid
    puts '--------------------------------------------------------------'    
    puts '                validate :all_generated_tests_valid            '
    puts self.exam
    puts '--------------------------------------------------------------'        
#      self.errors[:base] << "call from all_generated_tests_valid."
#     self.errors[:base] << "call from all_generated_tests_valid."
#    self.exam.errors[:base] << "call from all_generated_tests_valid."
#    errors.add(:exam_id, "Błąd! : call from all_generated_tests_valid.")
    self.errors.add(:base, "Błąd! : call from all_generated_tests_valid.")
    false
  end

  private

    def build_testportal_tests_and_save_identifiers
      # Rails.logger.info(' [DebugCode] before "run generate_testportal_tests"')
      puts '--------------------------------------------------------------'    
      puts ' after_initialize :build_testportal_tests_and_save_identifiers'

      puts self.subjects.ids

      errors[:base] << "Nie moge wygenerować testów."
      puts '--------------------------------------------------------------'    

      #self.testportal_test_id = Time.now.strftime("%Y-%m-%d %H:%M:%S:%N")
    end
  
end
