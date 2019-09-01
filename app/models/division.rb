class Division < ActiveRecord::Base

  DIVISION_M_G1E = 9  # G1E "świadectwo radioelektronika pierwszej klasy GMDSS"
  DIVISION_M_G2E = 10 # G2E "świadectwo radioelektronika pierwszej klasy GMDSS"
  DIVISION_M_GOC = 11 # GOC "świadectwo ogólne operatora GMDSS"
  DIVISION_M_ROC = 12 # ROC "świadectwo ograniczone operatora GMDSS"
  DIVISION_M_LRC = 13 # LRC "świadectwo operatora łączności dalekiego zasięgu LRC"
  DIVISION_M_SRC = 14 # SRC "świadectwo operatora łączności bliskiego zasięgu SRC"
  DIVISION_M_VHF = 15 # VHF "świadectwo operatora radiotelefonisty VHF"
  DIVISION_M_CSO = 16 # CSO "świadectwo operatora stacji nadbrzeżnej CSO"
  DIVISION_M_IWC = 17 # IWC "świadectwo operatora radiotelefonisty w służbie śródlądowej IWC"

  DIVISION_M_FOR_SHOW = [ DIVISION_M_LRC, DIVISION_M_SRC, DIVISION_M_VHF, DIVISION_M_CSO, DIVISION_M_IWC ]  

  DIVISION_R_A = 18
  DIVISION_R_B = 19
  DIVISION_R_C = 20
  DIVISION_R_D = 21

  DIVISION_R_FOR_SHOW = [ DIVISION_R_A, DIVISION_R_C ]  

  has_many :proposals  
  has_many :exam_fees  
  has_many :certificates  
  has_many :subjects, dependent: :destroy  

  accepts_nested_attributes_for :subjects

  # validates
  validates :name, presence: true, uniqueness: { :case_sensitive => false, :scope => [:category] }
  validates :category, presence: true, inclusion: { in: %w(L M R) }
  validates :short_name, presence: true
  validates :number_prefix, presence: true


  # scopes
  scope :only_category_scope, ->(cat)  { where(category: cat.upcase) }
  scope :by_name, -> { order(:name) }

end
