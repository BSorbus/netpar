class Grade < ActiveRecord::Base
  belongs_to :examination
  belongs_to :subject
  belongs_to :user

  def grade_result_name
    case grade_result
    when 'N'
      'Negatywna'
    when 'P'
      'Pozytywna'
    when '', nil
      ''
    else
      'Error !'
    end  
  end

end
