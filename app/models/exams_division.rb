class ExamsDivision < ActiveRecord::Base
  belongs_to :exam
  belongs_to :division

  has_many :exams_divisions_subjects, dependent: :destroy
  has_many :subjects, through: :division

  accepts_nested_attributes_for :exams_divisions_subjects, reject_if: :all_blank, allow_destroy: true
  validates_associated :exams_divisions_subjects


  # callbacks
  after_initialize :build_exams_divisions_subjects_for_testportal, if: "self.new_record?"


  def flat_all_exams_divisions_subjects
    self.exams_divisions_subjects.order(:id).flat_map {|row| "<div>[#{row.subject.item}] #{row.subject.name} #{row.colorized_testportal_id}</div>" }.join(' <br>').html_safe
  end

  private

    def build_exams_divisions_subjects_for_testportal
      Division.find(self.division_id).subjects.order(:item).each do |subiect|
        self.exams_divisions_subjects.build(subject_id: subiect.id) #unless self.exams_divisions_subjects.build(subject_id: subiect.id)
      end
    end
  
end
