class Customer < ActiveRecord::Base
  belongs_to :nationality
  belongs_to :citizenship
  belongs_to :user

  has_many :documents, as: :documentable
  has_many :works, as: :trackable

  has_many :individuals
  has_many :individualed_documentable, through: :individuals, source: :documents

  has_many :certificates
  has_many :certificated_documentable, through: :certificates, source: :documents

  has_many :examinations
  has_many :examinationed_documentable, through: :examinations, source: :documents

  has_many :exams, through: :certificates
  has_many :examed_documentable, through: :exams, source: :documents



  validates :name, presence: true,
                    length: { in: 1..160 }
#  validates :given_names, presence: true,
#                    length: { in: 1..50 }, if: :is_human? 
#  validates :address_city, presence: true,
#                    length: { in: 1..50 }
#  validates :pesel, length: { is: 11 }, numericality: true, 
#                    uniqueness: { case_sensitive: false }, allow_blank: true
#  validates :birth_date, presence: true, if: :is_human?
#  validate :check_pesel_and_birth_date, unless: "pesel.blank?"

  validates :nationality, presence: true
  validates :citizenship, presence: true
  validates :user, presence: true

  require 'pesel'

  def check_pesel_and_birth_date
    p = Pesel.new(pesel)
    errors.add(:pesel, ' - Błędny numer') unless p.valid?
    if p.valid? 
      errors.add(:birth_date, " niezgodna z datą zapisaną w numerze PESEL (#{p.birth_date})") unless p.birth_date == birth_date
    end
  end

  def is_human?
    human == true
  end

  def fullname
    "#{name} #{given_names}"
  end

  def fullname_and_id
    "#{name} #{given_names} (#{id})"
  end

  def fullname_and_address
    res = "#{name} #{given_names}, #{address_city}"
    res +=  ", ul.#{address_street}" if address_street.present?
    res +=  " #{address_house}" if address_house.present?
    res +=  "/#{address_number}" if address_number.present?
    res
  end

  def fullname_and_address_and_pesel_nip
    res = fullname_and_address
    res +=  ", #{pesel}" if pesel.present?
    res +=  ", #{nip}" if nip.present?
    res
  end

  def fullname_and_address_and_pesel_nip_and_birth_date
    res = fullname_and_address_and_pesel_nip
    res +=  ", ur.#{birth_date}" if birth_date.present?
    res
  end

  def birth_date_and_place
    str = birth_date.present? ? birth_date.strftime("%d.%m.%Y") : "" 
    "#{str} #{birth_place}"
  end


#  scope :finder_customer, ->(q) { where("(customers.name ilike :q or customers.given_names ilike :q 
#      or customers.address_city ilike :q or customers.pesel ilike :q)", q: "%#{q}%") }

#  scope :finder_customer, ->(q) { where('((((CAST("customers"."name" AS VARCHAR) ILIKE :q 
#      OR CAST("customers"."given_names" AS VARCHAR) ILIKE :q) 
#      OR CAST("customers"."address_city" AS VARCHAR) ILIKE :q) 
#      OR CAST("customers"."pesel" AS VARCHAR) ILIKE :q) 
#      OR CAST("customers"."nip" AS VARCHAR) ILIKE :q)', q: "%#{q}%") }

  scope :finder_customer, ->(q) { where( my_sql("#{q}") ) }

  def self.my_sql(query_str)
    array_params_query = query_str.split
    sql_string = ""
    array_params_query.each_with_index do |par, index|
      sql_string += " AND " unless index == 0
      sql_string += one_param_sql(par)
    end
    sql_string
  end

  def self.one_param_sql(query_str)
    "(customers.name ilike '%#{query_str}%' or 
      customers.given_names ilike '%#{query_str}%' or 
      customers.address_city ilike '%#{query_str}%' or 
      to_char(customers.birth_date,'YYYY-mm-dd') ilike '%#{query_str}%' or 
      customers.pesel ilike '%#{query_str}%')"
  end


# To działa dobrze:
#  def self.my_sql(query_str)
#    query_str.split.map { |par| one_param_sql(par) }.join(" AND ")
#  end
#
#  def self.one_param_sql(query_str)
#    escaped_query_str = sanitize("%#{query_str}%")
#
#    "(" + %w(name given_names address_city).map { |column| "customers.#{column} ilike #{escaped_query_str}" }.join(" OR ") + ")"
#  end


  # odblokuj, gdy w kontrolerze cesz użyc .as_json
  def as_json(options)
    { id: id, fullname_and_address_and_pesel_nip_and_birth_date: fullname_and_address_and_pesel_nip_and_birth_date }
  end


  def join_with_another(source_customer)
    unless self.id == source_customer.id
      source_customer.certificates.update_all(customer_id: self.id)
      source_customer.individuals.update_all(customer_id: self.id)
      source_customer.destroy!
    end
  end

end
