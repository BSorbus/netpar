class Exam < ActiveRecord::Base
  belongs_to :user
  has_many :certificates
  has_many :examinations



  has_many :documents, as: :documentable
  has_many :customers, through: :certificates
  has_many :customers, through: :examinations

#  validates :number, presence: true,
#                    length: { in: 1..30 },
#                    :uniqueness => { :case_sensitive => false, :scope => [:category] }

	scope :only_category_l, -> { where(category: "L") }
	scope :only_category_m, -> { where(category: "M") }
	scope :only_category_r, -> { where(category: "R") }

  before_save { self.number = number.upcase }

  def fullname
    "#{number}, z dn. #{date_exam}, #{place_exam}"
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


end
