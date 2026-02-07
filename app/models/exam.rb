require 'esodes'

class Exam < ActiveRecord::Base
  belongs_to :user
 
  has_many :certificates, dependent: :destroy
  has_many :examinations, dependent: :destroy
  has_many :exams_divisions, dependent: :destroy
  has_many :proposals, dependent: :destroy
  has_many :examiners, inverse_of: :exam, dependent: :destroy  

  # accepts_nested_attributes_for :examiners,
  #                               reject_if: proc { |attributes| attributes['name'].blank? },
  #                               allow_destroy: true

  has_many :works, as: :trackable
  has_many :documents, as: :documentable, dependent: :destroy

  has_many :certificate_customers, through: :certificates, source: :customer
  has_many :examination_customers, through: :examinations, source: :customer
  has_many :esod_matters, class_name: "Esod::Matter", foreign_key: :exam_id, dependent: :nullify

  has_many :divisions, through: :exams_divisions
  has_many :subjects, through: :exams_divisions
  has_many :exams_divisions_subjects, through: :exams_divisions

  has_many :grades, through: :examinations

  accepts_nested_attributes_for :examiners, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :exams_divisions, reject_if: :all_blank, allow_destroy: true

  # validates
  validates_associated :examiners
  validates_associated :exams_divisions

  validates :esod_category, presence: true, inclusion: { in: Esodes::ALL_CATEGORIES_EXAMS }
  validates :number, presence: true,
                    length: { in: 1..30 },
                    :uniqueness => { :case_sensitive => false, :scope => [:category] }

  validates :date_exam, presence: true
  validates :place_exam, presence: true,
                    length: { in: 1..50 }
  validates :info, presence: true, 
                    length: { in: 1..60 }
  validates :category, presence: true, inclusion: { in: %w(L M R) }
  validates :user, presence: true

  validates :province_id, presence: true, if: "(online == false)"
  validates :province_id, absence: true, if: "(online == true)"
  validates :max_examinations, numericality: true, allow_blank: true

#  validates :esod_matter, uniqueness: { case_sensitive: false }, allow_blank: true
  validate :exam_has_examinations, on: :update, if: :important_data_changed 
#  validate :exam_has_valid_exams_divisions_and_subjects#, on: :update, if: "(online == true)"
  validate :used_exams_divisions_presence


#translation missing: pl.activerecord.errors.models.exam.attributes.base.nested_taken
  validate_nested_uniqueness_of :exams_divisions, uniq_key: :division_id, scope: [:exam], case_sensitive: false, error_key: :exams_divisions_nested_taken

#   validate_nested_uniqueness_of :features, uniq_key: :feature_type_id, scope: [:featurable], case_sensitive: false, error_key: :nested_taken

  # scopes
	scope :only_category_l, -> { where(category: "L") }
	scope :only_category_m, -> { where(category: "M") }
	scope :only_category_r, -> { where(category: "R") }

  # callbacks
  before_save { self.number = number.upcase }
  before_save :save_province_name, if: :province_id_changed? 
  before_destroy :exam_has_links, prepend: true

  def important_data_changed
    (esod_category != esod_category_was) || 
    (date_exam != date_exam_was) || 
    (place_exam != place_exam_was) || 
    (info != info_was) || 
    (online != online_was)
  end

  def save_province_name
    if province_id.present?
      province = ApiTerytProvince.new(id: province_id)
      province.request_for_one_row
      province_hash = JSON.parse(province.response.body)
      self.province_name = province_hash.fetch('name', '') if province_hash.present?
    else
      self.province_name = ''
    end
  end


  def fullname
    "#{number}, z dn. #{date_exam}, #{place_exam} [#{province_name}] #{info}"
  end

  def fullname_and_id
    "#{number}, z dn. #{date_exam}, #{place_exam} [#{province_name}] #{info}(#{id})"
  end

  def place_and_date
    "#{place_exam}, dn. #{date_exam}"
  end

  def esod_category_name
    Esodes::esod_matter_iks_name(esod_category)
  end

  def flat_all_esod_matters
    self.esod_matters.order(:id).flat_map {|row| row.znak }.join(' <br>').html_safe
  end

  def refresh_proposals_important_count
    update_columns(proposals_important_count: proposals.where(proposal_status_id: ProposalStatus::PROPOSAL_IMPORTANT_STATUSES).size)
  end

  def all_exams_divisions_subjects_has_testportal_id
    if self.online?
      self.exams_divisions_subjects.where(testportal_test_id: "").empty?
    else 
      true
    end
  end

  def exam_has_examinations
    analize_value = true
    if self.examinations.any?
      errors.add(:esod_category, " - Nie można zmieniać Rodzaju Sesjido której są przypisane Osoby Egzaminowane.") if (esod_category != esod_category_was)
      errors.add(:date_exam, " - Nie można zmieniać Daty Sesji do której są przypisane Osoby Egzaminowane.") if (date_exam != date_exam_was)
      errors.add(:place_exam, " - Nie można zmieniać Miejsca Sesji do której są przypisane Osoby Egzaminowane.") if (place_exam != place_exam_was)
      errors.add(:online, " - Nie można zmieniać Sesja/Sesja Online do której są przypisane Osoby Egzaminowane.") if (online != online_was)
      analize_value = false
    end
    if self.proposals.any? 
      errors.add(:esod_category, " - Nie można zmieniać Rodzaju Sesji do której są złożone Elektronicznie Zgłoszenia.") if (esod_category != esod_category_was)
      errors.add(:date_exam, " - Nie można zmieniać Daty Sesji do której są złożone Elektronicznie Zgłoszenia.") if (date_exam != date_exam_was)
      errors.add(:place_exam, " - Nie można zmieniać Miejsca Sesji do której są złożone Elektronicznie Zgłoszenia.") if (place_exam != place_exam_was)
      errors.add(:online, " - Nie można zmieniać Sesja/Sesja Online do której są złożone Elektronicznie Zgłoszenia.") if (online != online_was)
      errors.add(:info, " - Nie można zmieniać Informacji dodatkowych o Sesji do której są złożone Elektronicznie Zgłoszenia.") if ((info != info_was) && info_was != '')  
      analize_value = false
    end
    analize_value
  end

  def exam_has_links
    analize_value = true
    if self.certificates.any? 
      errors[:base] << "Nie można usunąć Egzaminu do którego są przypisane Świadectwa."
      analize_value = false
    end
    if self.examinations.any? 
      errors[:base] << "Nie można usunąć Egzaminu do którego są przypisane Osoby Egzaminowane."
      analize_value = false
    end
    if self.proposals.any? 
      errors[:base] << "Nie można usunąć Egzaminu do którego są złożone Elektroniczne Zgłoszenia."
      analize_value = false
    end
    analize_value
  end

  def exam_has_valid_exams_divisions
    puts '--------------------------------------------------------------'    
    puts '                validate :exam_has_valid_exams_divisions      '
    puts '--------------------------------------------------------------'        
#      self.errors[:base] << "call from :exam_has_valid_exams_divisions."

  end
  
  # Scope for select2: "exam_select"
  # * parameters   :
  #   * +query_str+ -> string for search. 
  #   Ex.: "M/2015 war"
  # * result   :
  #   * +scope+ -> collection 
  #
  scope :finder_exam, ->(q, category) { where( create_sql_string("#{q}", "#{category}") ) }

  # Method create SQL query string for finder select2: "exam_select"
  # * parameters   :
  #   * +category_scope+ -> category of exam %w(l m r). 
  #   * +query_str+ -> string for search. 
  #   Ex.: "M/2015 war"
  # * result   :
  #   * +sql_string+ -> string for SQL WHERE... 
  #
  def self.create_sql_string(query_str, category_scope)
    if query_str.blank?
      str_sql = "(exams.category = '#{category_scope}')"
    else
      str_sql = "(exams.category = '#{category_scope}') AND " + query_str.split.map { |par| one_param_sql(par) }.join(" AND ")
    end

    return str_sql
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
    "(" + %w(exams.number to_char(exams.date_exam,'YYYY-mm-dd') exams.place_exam exams.province_name exams.info).map { |column| "#{column} ilike #{escaped_query_str}" }.join(" OR ") + ")"
  end

  def generate_all_certificates(gen_user_id)
    for_generate_examinations =  Examination.joins(:division, :customer, :exam).where(exam_id: self.id, certificate: nil, examination_result: 'P').
                                  includes(:division, :customer, :exam, :certificate).references(:division, :customer, :exam, :certificate).order(:id).all
    for_generate_examinations.each do |examination|
      examination.generate_certificate(gen_user_id)
    end

  end


  def self.to_csv
    CSV.generate(headers: false, col_sep: ';', converters: nil, skip_blanks: false, force_quotes: false) do |csv|
      columns_header = [
        "Lp.",
        "Numer", 
        "Data", 
        "Miejsce", 
        "Wniosek o wydanie świadectwa 1", 
        "Wniosek o egzamin poprawkowy 1",
        "Negatywny bez prawa do poprawki 1", 
        "Negatywny z prawem do poprawki 1",
        "Nieobecny 1", 
        "Zmiana terminu 1", 
        "pozytywny 1",
        "Wniosek o wydanie świadectwa 3", 
        "Wniosek o egzamin poprawkowy 3",
        "Negatywny bez prawa do poprawki 3", 
        "Negatywny z prawem do poprawki 3",
        "Nieobecny 3", 
        "Zmiana terminu 3", 
        "pozytywny 3",
        "Wnioski suma 1",
        "Negatywni suma 1",
        "Nieobecni i zmiana terminu suma 1",
        "Obecni suma 1",
        "Obecni i nieobecni suma 1",
        "Wnioski suma 3",
        "Negatywni suma 3",
        "Nieobecni i zmiana terminu suma 3",
        "Obecni suma 3",
        "Obecni i nieobecni suma 3",
        "Wnioski suma",
        "Negatywni suma", 
        "Nieobecni i zmiana terminu suma", 
        "Obecni suma", 
        "Obecni i nieobecni suma", 
        "Pozytywni suma",
        "% nieobecnych", 
        "Liczba miejsc", 
        "% obłożenia"
      ]

      csv << columns_header

      colA = 0
      all.each do |rec|
        examinations = rec.examinations
        colA += 1
        colB  = "#{rec.number}"
        colC  = "#{rec.date_exam}"
        colD  = "#{rec.place_exam}"
        colE  = examinations.select{|e| (e.esod_category == Esodes::EGZAMIN)    && (e.division_id == Division::DIVISION_R_1)}.size
        colF  = examinations.select{|e| (e.esod_category == Esodes::POPRAWKOWY) && (e.division_id == Division::DIVISION_R_1)}.size
        colG  = examinations.select{|e| (e.examination_result == Examination::EX_RESULT_NEGATYWNY_BEZ_PRAWA) && (e.division_id == Division::DIVISION_R_1)}.size
        colH  = examinations.select{|e| (e.examination_result == Examination::EX_RESULT_NEGATYWNY_Z_PRAWEM)  && (e.division_id == Division::DIVISION_R_1)}.size
        colI  = examinations.select{|e| (e.examination_result == Examination::EX_RESULT_NIEOBECNY)           && (e.division_id == Division::DIVISION_R_1)}.size
        colJ  = examinations.select{|e| (e.examination_result == Examination::EX_RESULT_ZMIANA_TERMINU)      && (e.division_id == Division::DIVISION_R_1)}.size
        colK  = examinations.select{|e| (e.examination_result == Examination::EX_RESULT_POZYTYWNY)           && (e.division_id == Division::DIVISION_R_1)}.size
        colL  = examinations.select{|e| (e.esod_category == Esodes::EGZAMIN)    && (e.division_id == Division::DIVISION_R_3)}.size
        colM  = examinations.select{|e| (e.esod_category == Esodes::POPRAWKOWY) && (e.division_id == Division::DIVISION_R_3)}.size
        colN  = examinations.select{|e| (e.examination_result == Examination::EX_RESULT_NEGATYWNY_BEZ_PRAWA) && (e.division_id == Division::DIVISION_R_3)}.size
        colO  = examinations.select{|e| (e.examination_result == Examination::EX_RESULT_NEGATYWNY_Z_PRAWEM)  && (e.division_id == Division::DIVISION_R_3)}.size
        colP  = examinations.select{|e| (e.examination_result == Examination::EX_RESULT_NIEOBECNY)           && (e.division_id == Division::DIVISION_R_3)}.size
        colQ  = examinations.select{|e| (e.examination_result == Examination::EX_RESULT_ZMIANA_TERMINU)      && (e.division_id == Division::DIVISION_R_3)}.size
        colR  = examinations.select{|e| (e.examination_result == Examination::EX_RESULT_POZYTYWNY)           && (e.division_id == Division::DIVISION_R_3)}.size
        colS  = colE + colF         # "S Wnioski suma 1"
        colT  = colG + colH         # "T Negatywni suma 1"
        colU  = colI + colJ         # "U Nieobecni i zmiana terminu suma 1"
        colV  = colG + colH + colK  # "V Obecni suma 1"
        colW  = colU + colV         # "W Obecni i nieobecni suma 1"
        colX  = colL + colM         # "X Wnioski suma 3"
        colY  = colN + colO         # "Y Negatywni suma 3"
        colZ  = colP + colQ         # "Z Nieobecni i zmiana terminu suma 3"
        colAA = colN + colO + colR  # "AA Obecni suma 3"
        colAB = colZ + colAA        # "AB Obecni i nieobecni suma 3"
        colAC = colS + colX         # "AC Wnioski suma" =[@[Wnioski suma 1]]+[@[Wnioski suma 3]]
        colAD = colT + colY         # "AD Negatywni suma" =[@[Negatywni suma 1]]+[@[Negatywni suma 3]]
        colAE = colU + colZ         # "AE Nieobecni i zmiana terminu suma" =[@[Nieobecni i zmiana terminu suma 1]]+[@[Nieobecni i zmiana terminu suma 3]]
        colAF = colV + colAA        # "AF Obecni suma" =[@[Obecni suma 1]]+[@[Obecni suma 3]]
        colAG = colW + colAB        # "AG Obecni i nieobecni suma" =[@[Obecni i nieobecni suma 1]]+[@[Obecni i nieobecni suma 3]]
        colAH = colK + colR         # "AH Pozytywni suma" =[@[Pozytywny 1]]+[@[Pozytywny 3]]
        colAI = colAG.zero? ? nil : colAE.to_f / colAG.to_f # "AI % nieobecnych" =[@[Nieobecni i zmiana terminu suma]]/[@[Obecni i nieobecni suma]]
        colAJ = rec.max_examinations.to_i         # "AJ Liczba miejsc"  
        colAK = colAJ.zero? ? nil : colAG.to_f / colAJ.to_f # "AK % obłożenia" =[@[Obecni i nieobecni suma]]/[@[Liczba miejsc]]

        csv << [ colA,colB,colC,colD,colE,colF,colG,colH,colI,colJ,colK,colL,colM,colN,colO,colP,colQ,colR,colS,colT,
                 colU,colV,colW,colX,colY,colZ,colAA,colAB,colAC,colAD,colAE,colAF,colAG,colAH,colAI,colAJ,colAK ]


     end
    end #.encode('WINDOWS-1250')
  end

  def force_destroy

    self.esod_matters.each do |em|
      em.esod_matter_notes.each do |r|
        r.destroy
      end
      em.esod_incoming_letters_matters.each do |r|
        r.destroy
      end
      em.esod_outgoing_letters_matters.each do |r|
        r.destroy
      end
      em.esod_internal_letters_matters.each do |r|
        r.destroy
      end
      em.destroy
    end
    puts '------------------------'
    puts 'end esod_matters'
    puts '------------------------'

    self.documents.each do |r|
      r.destroy
    end
    puts '------------------------'
    puts 'end documents'
    puts '------------------------'

    self.examiners.each do |r|
      r.destroy
    end
    puts '------------------------'
    puts 'examiners'
    puts '------------------------'

    self.grades.each do |r|
      r.destroy
    end
    puts '------------------------'
    puts 'end grades'
    puts '------------------------'

    self.exams_divisions_subjects.each do |r|
      r.destroy
    end
    puts '------------------------'
    puts 'end exams_divisions_subjects'
    puts '------------------------'

    self.exams_divisions.each do |r|
      r.destroy
    end
    puts '------------------------'
    puts 'end exams_divisions'
    puts '------------------------'

    self.certificates.each do |r|
      unless r.destroy
        puts '======================== certificate ======================='
        puts r.errors
        puts '========================================================='
      end
    end
    puts '------------------------'
    puts 'end certificates'
    puts '------------------------'

    self.proposals.each do |r|
      unless r.destroy
        puts '======================== proposal ======================='
        puts r.errors
        puts '========================================================='
      end
    end
    puts '------------------------'
    puts 'end proposals'
    puts '------------------------'
    self.examinations.each do |r|
      unless r.destroy
        puts '======================= examinaton ======================'
        puts r.errors
        puts '========================================================='
      end
    end
    puts '------------------------'
    puts 'end examinations'
    puts '------------------------'

    self.reload
    self.destroy
  end

  private

    # def used_exams_divisions_presence
    #   if exams_divisions.reject(&:marked_for_destruction?).reject { |x| not FeatureType.only_address_ext_type_email.ids.include?(x.feature_type_id) }.empty?
    #     key_names = FeatureType.only_address_ext_type_email.pluck(:name).flatten
    #     errors.add(:base, :exams_divisions_used_presence, data: key_names)
    #   end
    # end

    def used_exams_divisions_presence
      exams_divisions_ids_not_marked = exams_divisions.reject(&:marked_for_destruction?).map(&:division_id)
      exams_divisions_ids_all = exams_divisions.pluck(:division_id)
      exams_divisions_ids_for_destroy = exams_divisions_ids_all - exams_divisions_ids_not_marked

      exams_divisions_ids_for_destroy.each do |division_key|         
        if examinations.where(division_id: division_key).any? || proposals.where(division_id: division_key, proposal_status_id: ProposalStatus::PROPOSAL_IMPORTANT_STATUSES).any?
          key_names = Division.find(division_key).short_name
          errors.add(:base, :exams_divisions_used_presence, data: key_names)
        end
      end
    end

end
