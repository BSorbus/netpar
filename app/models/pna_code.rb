class PnaCode < ActiveRecord::Base

  # validates
  validates :pna, presence: true,
                  length: { in: 6..10 }
  validates :miejscowosc, presence: true 
  validates :wojewodztwo, presence: true 
  validates :powiat, presence: true 
  validates :gmina, presence: true 


  # Scope for select2: "pna_code_select"
  # * parameters   :
  #   * +query_str+ -> string for search. 
  #   Ex.: "85 wyzwol"
  # * result   :
  #   * +scope+ -> collection 
  #
  scope :finder_pna_code, ->(q) { where( create_sql_string("#{q}") ) }

  # Method create SQL query string for finder select2: "pna_code_select"
  # * parameters   :
  #   * +query_str+ -> string for search. 
  #   Ex.: "85 wyzwol"
  # * result   :
  #   * +sql_string+ -> string for SQL WHERE... 
  #   Ex.: "((pna_codes.pna ilike '%85%' OR pna_codes.miejscowosc ilike '%85%' OR pna_codes.ulica ilike '%85%' OR pna_codes.powiat ilike '%85%' OR pna_codes.gmina ilike '%85%' ) AND (pna_codes.pna ilike '%wyzw%' OR pna_codes.miejscowosc ilike '%wyzwol%' OR pna_codes.ulica ilike '%wyzwol%' OR pna_codes.powiat ilike '%wyzwol%' OR pna_codes.gmina ilike '%wyzwol%'))"
  #
  def self.create_sql_string(query_str)
    query_str.split.map { |par| one_param_sql(par) }.join(" AND ")
  end

  # Method for glue parameters in create_sql_string
  # * parameters   :
  #   * +query_str+ -> word for search. 
  #   Ex.: "85"
  # * result   :
  #   * +sql_string+ -> SQL string query for one word 
  #   Ex.: "(pna_codes.pna ilike '%85%' OR pna_codes.miejscowosc ilike '%85%' OR pna_codes.ulica ilike '%85%' OR pna_codes.powiat ilike '%85%' OR pna_codes.gmina ilike '%85%' ) "
  #
  def self.one_param_sql(query_str)
    escaped_query_str = sanitize("%#{query_str}%")
    "(" + %w(pna_codes.pna pna_codes.miejscowosc pna_codes.ulica pna_codes.gmina pna_codes.powiat).map { |column| "#{column} ilike #{escaped_query_str}" }.join(" OR ") + ")"
  end

end
