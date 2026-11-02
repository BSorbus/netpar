class Work < ActiveRecord::Base
  belongs_to :trackable, polymorphic: true
  belongs_to :user

  def action_name
    case action
    when 'create'
      'utworzył kartotekę'
    when 'update'
      'zmodyfikował kartotekę'
    when 'destroy'
      'usunął kartotekę'
    when 'regenerate_verification_code'
      'nadał nowy kod weryfikacji (QR karty)'
    else
      'Error action value !'
    end  
  end

  def pretty_parameters
    JSON.pretty_generate(JSON.parse(self.parameters.gsub('":"', '": "')))
  end

end
