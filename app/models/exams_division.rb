class ExamsDivision < ActiveRecord::Base
  belongs_to :exam
  belongs_to :division
end
