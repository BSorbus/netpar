class Esod::Matter < ActiveRecord::Base
   has_one :exam, foreign_key: :esod_matter_id, dependent: :nullify
#  belongs_to :examination
#  belongs_to :certificate

  def fullname
    "#{znak} (#{tytul}) #{termin_realizacji}"
  end

  def iks_name
    case identyfikator_kategorii_sprawy
    when 41
      'Wniosek o wydanie świadectwa'
    when 42
      'Wniosek o egzamin poprawkowy'
    when 43
      'Wniosek o odnowienie bez egzaminu'
    when 44
      'Wniosek o odnowienie z egzaminem'
    when 45
      'Wniosek o duplikat'
    when 46
      'Wniosek o wymianę świadectwa'
    when 47
      'Sesja egzaminacyjna'
    when 48
      'Protokół egzaminacyjny'
    else
      "Error identyfikator_kategorii_sprawy value (#{identyfikator_kategorii_sprawy})!"
    end
  end

  # Scope for select2: "exam_select"
  # * parameters   :
  #   * +query_str+ -> string for search. 
  #   Ex.: "M/2015 war"
  # * result   :
  #   * +scope+ -> collection 
  #
  scope :finder_esod_matter, ->(q, iks, jrwa) { where( create_sql_string("#{q}", "#{iks}", "#{jrwa}") ) }
 
  # Method create SQL query string for finder select2: "exam_select"
  # * parameters   :
  #   * +jrwa_scope+ -> jrwa of exam %w(l m r). 
  #   * +query_str+ -> string for search. 
  #   Ex.: "M/2015 war"
  # * result   :
  #   * +sql_string+ -> string for SQL WHERE... 
  #
  def self.create_sql_string(query_str, iks_scope, jrwa_scope)
    "(esod_matters.identyfikator_kategorii_sprawy IN #{iks_scope}) AND (esod_matters.symbol_jrwa IN #{jrwa_scope}) AND " + query_str.split.map { |par| one_param_sql(par) }.join(" AND ")
  end

  # Method for glue parameters in create_sql_string
  # * parameters   :
  #   * +query_str+ -> word for search. 
  #   Ex.: "war"
  # * result   :
  #   * +sql_string+ -> SQL string query for one word 
  #
  def self.one_param_sql(query_str)
    escaped_query_str = sanitize("%#{query_str}%")
    "(" + %w(esod_matters.znak esod_matters.tytul to_char(esod_matters.termin_realizacji,'YYYY-mm-dd') ).map { |column| "#{column} ilike #{escaped_query_str}" }.join(" OR ") + ")"
  end



end
