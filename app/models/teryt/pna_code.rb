class Teryt::PnaCode < ActiveRecord::Base

  # validates
  validates :sym_nazwa, presence: true 
  validates :woj_nazwa, presence: true 
  validates :pow_nazwa, presence: true 
  validates :gmi_nazwa, presence: true 
  validates :teryt, presence: true 
  #validates :pna, presence: true
  #validates :pna_teryt, presence: true 

  # 'wyspa', 'szosa', 'al.', 'os.', 'park', 'bulw.', 'wyb.', 'rynek', 'ul.', 'rondo', 'pl.', 'skwer', 'droga', 'ogród', 'inne'

  def uli_cecha_nazwa
    if ['al.', 'os.', 'ul.', 'pl.', 'wyb.'].include?("#{cecha}")
      "#{cecha} #{uli_nazwa}".strip 
    else 
      if ['WYSPA', 'SZOSA', 'PARK', 'BULWAR', 'RYNEK', 'RONDO', 'SKWER', 'DROGA', 'OGRÓD' ].any? { |i| "#{uli_nazwa}".upcase.split.include?(i) }
        "#{uli_nazwa}" 
      else
        "#{cecha}" == 'inne' ? "#{uli_nazwa}" : "#{cecha} #{uli_nazwa}".strip       
      end
    end
  end


  # Scope for select2: "teryt_pna_code_select"
  # * parameters   :
  #   * +query_str+ -> string for search. 
  #   Ex.: "85 wyzwol"
  # * result   :
  #   * +scope+ -> collection 
  #
  scope :finder_teryt_pna_code, ->(q) { where( create_sql_string("#{q}") ) }

  # Method create SQL query string for finder select2: "teryt_pna_code_select"
  # * parameters   :
  #   * +query_str+ -> string for search. 
  #   Ex.: "85 wyzwol"
  # * result   :
  #   * +sql_string+ -> string for SQL WHERE... 
  #   Ex.: "((teryt_pna_codes.pna ilike '%85%' OR teryt_pna_codes.sym_nazwa ilike '%85%' OR teryt_pna_codes.sympod_nazwa ilike '%85%' OR teryt_pna_codes.uli_nazwa ilike '%85%' OR teryt_pna_codes.gmi_nazwa ilike '%85%' OR teryt_pna_codes.pow_nazwa ilike '%85%' ) AND (teryt_pna_codes.pna ilike '%wyzw%' OR teryt_pna_codes.sym_nazwa ilike '%wyzwol%' OR teryt_pna_codes.sympod_nazwa ilike '%wyzwol%' OR teryt_pna_codes.uli_nazwa ilike '%wyzwol%' OR teryt_pna_codes.gmi_nazwa ilike '%wyzwol%' OR teryt_pna_codes.pow_nazwa ilike '%wyzwol%'))"
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
  #   Ex.: "(teryt_pna_codes.pna ilike '%85%' OR teryt_pna_codes.sym_nazwa ilike '%85%'  OR teryt_pna_codes.sympod_nazwa ilike '%85%' OR teryt_pna_codes.uli_nazwa ilike '%85%' OR teryt_pna_codes.gmi_nazwa ilike '%85%' OR teryt_pna_codes.pow_nazwa ilike '%85%' ) "
  #
  def self.one_param_sql(query_str)
    escaped_query_str = sanitize("%#{query_str}%")
    # "(" + %w(teryt_pna_codes.pna teryt_pna_codes.sym_nazwa teryt_pna_codes.uli_nazwa teryt_pna_codes.gmi_nazwa teryt_pna_codes.pow_nazwa teryt_pna_codes.woj_nazwa).map { |column| "#{column} ilike #{escaped_query_str}" }.join(" OR ") + ")"
    "(" + %w(teryt_pna_codes.pna teryt_pna_codes.mie_nazwa teryt_pna_codes.uli_nazwa teryt_pna_codes.gmi_nazwa teryt_pna_codes.pow_nazwa teryt_pna_codes.woj_nazwa).map { |column| "#{column} ilike #{escaped_query_str}" }.join(" OR ") + ")"
  end


end
