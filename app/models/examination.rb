class Examination < ActiveRecord::Base
  belongs_to :division
  belongs_to :exam
  belongs_to :customer
  belongs_to :user

  belongs_to :certificate 

  has_many :works, as: :trackable
  has_many :documents, as: :documentable, :source_type => "Examination", dependent: :destroy

  has_many :grades, dependent: :destroy  

  accepts_nested_attributes_for :grades
  validates_associated :grades


  # validates

  


  # scopes
  scope :only_category_l, -> { where(category: "L") }
  scope :only_category_m, -> { where(category: "M") }
  scope :only_category_r, -> { where(category: "R") }

  def fullname
    "#{customer.fullname}  =>  #{exam.fullname}"
  end

  def fullname_and_id
    "#{customer.fullname}  =>  #{exam.fullname} (#{id})"
  end

  def examination_category_name
    case examination_category
    when 'Z'
      'Zwykły'
    when 'P'
      'Powtórny'
    else
      'Error !'
    end  
  end

  def examination_result_name
    case examination_result
    when 'B'
      'Negatywny bez prawa do powtórki'
    when 'N'
      'Negatywny z prawem do powtórki'
    when 'P'
      'Pozytywny'
    when '', nil
      ''
    else
      'Error !'
    end  
  end

  def generate_certificate(gen_user_id)
    exam = self.exam

    new_certificate = exam.certificates.create(number: Certificate.next_certificate_number(self.category, self.division), date_of_issue: Time.zone.today, user_id: gen_user_id, customer: self.customer, division: self.division, category: exam.category)
    self.certificate = new_certificate
    self.save! 
    new_certificate.works.create( trackable_url: "#{Rails.application.routes.url_helpers.certificate_path(new_certificate, category_service: new_certificate.category.downcase)}", action: :generate_certificate, user_id: gen_user_id, parameters: new_certificate.attributes.to_hash )
    #new_certificate.works.create( trackable_url: "#{certificate_path(new_certificate, category_service: new_certificate.category.downcase)}", action: :generate_certificate, user_id: gen_user_id, parameters: {number: new_certificate.number} )
    #Work.create!(trackable: new_certificate, action: :generate_certificate, user_id: gen_user_id, parameters: {number: new_certificate.number} ) 

  end


end
