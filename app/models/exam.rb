class Exam < ActiveRecord::Base
  belongs_to :user
  has_many :certificates, dependent: :destroy
  has_many :examinations, dependent: :destroy

  has_many :examiners, dependent: :destroy  

  accepts_nested_attributes_for :examiners,
                                reject_if: proc { |attributes| attributes['name'].blank? },
                                allow_destroy: true

  validates_associated :examiners

  has_many :works, as: :trackable

  has_many :documents, as: :documentable, dependent: :destroy
  has_many :customers, through: :certificates
  has_many :customers, through: :examinations



  # validates
  validates :number, presence: true,
                    length: { in: 1..30 },
                    :uniqueness => { :case_sensitive => false, :scope => [:category] }



  # scopes
	scope :only_category_l, -> { where(category: "L") }
	scope :only_category_m, -> { where(category: "M") }
	scope :only_category_r, -> { where(category: "R") }

  before_save { self.number = number.upcase }

  def fullname
    "#{number}, z dn. #{date_exam}, #{place_exam}"
  end

  def fullname_and_id
    "#{number}, z dn. #{date_exam}, #{place_exam} (#{id})"
  end

  def place_and_date
    "#{place_exam}, dn. #{date_exam}"
  end

  scope :finder_exam, ->(q, cat) { where( my_sql("#{cat}", "#{q}") ) }

  def self.my_sql(category_scope, query_str)
    array_params_query = query_str.split
    sql_string = "(exams.category = '#{category_scope}') AND "
    array_params_query.each_with_index do |par, index|
      sql_string += " AND " unless index == 0
      sql_string += one_param_sql(par)
    end
    sql_string
  end

  def self.one_param_sql(query_str)
    "(exams.number ilike '%#{query_str}%' or
      to_char(exams.date_exam,'YYYY-mm-dd') ilike '%#{query_str}%' or 
      exams.place_exam ilike '%#{query_str}%')"
  end

  # odblokuj, gdy w kontrolerze cesz użyc .as_json
  def as_json(options)
    { id: id, fullname: fullname }
  end


  def generate_all_certificates(gen_user_id)
    #for_generate_examinations = self.examinations.where(certificate: nil, examination_result: 'P').all? 

    for_generate_examinations =  Examination.joins(:division, :customer, :exam).where(exam_id: self.id, certificate: nil, examination_result: 'P').
                                  includes(:division, :customer, :exam, :certificate).references(:division, :customer, :exam, :certificate).order("customers.name, customers.given_names").all

    for_generate_examinations.each do |examination|

      examination.generate_certificate(gen_user_id)

    end

  end

end
