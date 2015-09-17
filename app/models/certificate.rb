class Certificate < ActiveRecord::Base
  belongs_to :division
  belongs_to :exam
  belongs_to :customer
  belongs_to :user

  has_one :examination, dependent: :nullify

  has_many :works, as: :trackable
  has_many :documents, as: :documentable, :source_type => "Certificate", dependent: :destroy



  # validates
  validates :number, presence: true,
                    length: { in: 1..30 },
                    uniqueness: { :case_sensitive => false, :scope => [:category] }
  validates :date_of_issue, presence: true
  validates :division, presence: true
  validates :customer, presence: true
  validates :exam, presence: true
  validates :user, presence: true
  validates :category, inclusion: { in: %w(L M R) }
  validate  :valid_thru_if_not_blank_must_more_date_of_issue, unless: "valid_thru.blank?"

 
  def valid_thru_if_not_blank_must_more_date_of_issue
    if valid_thru.present? && valid_thru < date_of_issue
      errors.add(:valid_thru, "nie może być mniejsza od daty wydania")
    end
  end 

  before_save { self.number = number.upcase }

  # scopes
	scope :only_category_l, -> { where(category: "L") }
	scope :only_category_m, -> { where(category: "M") }
	scope :only_category_r, -> { where(category: "R") }

  def fullname
    "#{number}, z dn. #{date_of_issue}"
  end

  def fullname_and_id
    "#{number}, z dn. #{date_of_issue} (#{id})"
  end

  def certificate_status_name
    case certificate_status
    when 'D'
      'Duplicat'   
    when 'N'
      'Nowe'
    when 'O'
      'Odnowione' 
    when 'S'
      'Skreślone (nieważne)' 
    when 'W'
      'Wymienione (odnowione)' 
    end
  end

  def self.next_certificate_number(category, division)
    case category.upcase
    when 'M'
      # TODO grupuj numeracje 
      next_nr = Certificate.get_next_number_certificate(category, division)
      if division.present?
        "#{division.number_prefix}#{next_nr}"
      else
        "#{category.upcase}-#{next_nr}"       
      end
    when 'L'
      next_nr = Certificate.get_next_number_certificate(category, division)
      if division.present?
        "#{division.number_prefix}#{next_nr}"
      else
        "L-#{next_nr}"       
      end
    when 'R'
      next_nr = Certificate.get_next_number_certificate(category, division)
      if division.present?
        "#{division.number_prefix}#{next_nr}"
      else
        "-#{next_nr}"       
      end
    else
      'Error !'
    end
  end

  def self.get_next_number_certificate(service, divis)
    #ret_val = connection.execute("SELECT max(abs(to_number(certificates.number,'999999999'))) AS max_cert FROM certificates WHERE certificates.category = 'R'")
    
    q_res = Certificate.find_by_sql( ["SELECT max(abs(to_number(certificates.number,'999999999'))) AS number FROM certificates WHERE certificates.category = ?", service.upcase] ).first.number
    q_res.to_f.round(0) + 1 
  end

end
