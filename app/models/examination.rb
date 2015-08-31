class Examination < ActiveRecord::Base
  belongs_to :division
  belongs_to :exam
  belongs_to :customer
  belongs_to :user

  belongs_to :certificate 

  has_many :documents, as: :documentable, :source_type => "Examination"


  scope :only_category_l, -> { where(category: "L") }
  scope :only_category_m, -> { where(category: "M") }
  scope :only_category_r, -> { where(category: "R") }

  def fullname
    "#{customer.fullname_and_address}  =>  #{exam.fullname}"
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

  def examination_resoult_name
    case examination_resoult
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

  def generate_certificate
    exam = self.exam

    new_certificate = exam.certificates.create(number: next_certificate_number(self.category, self.division), date_of_issue: Time.zone.today, user: exam.user, customer: self.customer, division: self.division, category: exam.category)
    self.certificate = new_certificate
    self.save! 
  end

  def next_certificate_number(category, division)
    case category
    when 'M'
      # TODO grupuj numeracje 
      next_nr = Certificate.get_next_number_certificate(category, division)
      "#{division.number_prefix}#{next_nr}"
    when 'L', 'R'
      next_nr = Certificate.get_next_number_certificate(category, division)
      "#{division.number_prefix}#{next_nr}"
    else
      'Error !'
    end
  end


end
