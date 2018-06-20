class License < ActiveRecord::Base


  def type_license_name
    case type_license
    when 'I'
      'Indywidualne'
    when 'K'
      'Klubowe'
    when 'B'
      'Bezobsługowe'
    else
      'Error grade_result value !'
    end  
  end
end
