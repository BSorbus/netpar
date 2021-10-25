class ExamsDivisionsSubject < ActiveRecord::Base
  belongs_to :exams_division
  belongs_to :subject
  
end
