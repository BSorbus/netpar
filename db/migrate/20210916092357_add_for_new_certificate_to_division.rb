class AddForNewCertificateToDivision < ActiveRecord::Migration

  DIVISION_M_G1E = 9  # G1E "świadectwo radioelektronika pierwszej klasy GMDSS"
  DIVISION_M_G2E = 10 # G2E "świadectwo radioelektronika pierwszej klasy GMDSS"
  DIVISION_M_GOC = 11 # GOC "świadectwo ogólne operatora GMDSS"
  DIVISION_M_ROC = 12 # ROC "świadectwo ograniczone operatora GMDSS"
  DIVISION_M_LRC = 13 # LRC "świadectwo operatora łączności dalekiego zasięgu LRC"
  DIVISION_M_SRC = 14 # SRC "świadectwo operatora łączności bliskiego zasięgu SRC"
  DIVISION_M_VHF = 15 # VHF "świadectwo operatora radiotelefonisty VHF"
  DIVISION_M_CSO = 16 # CSO "świadectwo operatora stacji nadbrzeżnej CSO"
  DIVISION_M_IWC = 17 # IWC "świadectwo operatora radiotelefonisty w służbie śródlądowej IWC"

  # DIVISION_M_FOR_SHOW = [ DIVISION_M_LRC, DIVISION_M_SRC, DIVISION_M_VHF, DIVISION_M_CSO, DIVISION_M_IWC ]  

  DIVISION_R_A = 18
  DIVISION_R_B = 19
  DIVISION_R_C = 20
  DIVISION_R_D = 21

#  DIVISION_R_FOR_SHOW = [ DIVISION_R_A, DIVISION_R_C ]  

  DIVISION_EXCLUDE_FOR_NEW = [ DIVISION_R_B, DIVISION_R_D ]  
  DIVISION_EXCLUDE_FOR_INTERNET = [ DIVISION_R_B, DIVISION_R_D, DIVISION_M_G1E, DIVISION_M_G2E, DIVISION_M_GOC, DIVISION_M_ROC, DIVISION_M_CSO ]  

  def up
    add_column :divisions, :for_new_certificate, :boolean, null: false, default: true

    Division.where(id: DIVISION_EXCLUDE_FOR_NEW ).update_all(for_new_certificate: false)
  end

  def down
    remove_column :divisions, :for_new_certificate
  end
end