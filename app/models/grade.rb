class Grade < ActiveRecord::Base
  belongs_to :examination
  belongs_to :subject
  belongs_to :user

  # validates
  validates :examination, presence: true
  validates :subject, presence: true
  validates :user, presence: true
  validates :grade_result, inclusion: { in: ["", nil, "N", "P"] }


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
    
  end

end
