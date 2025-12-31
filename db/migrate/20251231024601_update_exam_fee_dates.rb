class UpdateExamFeeDates < ActiveRecord::Migration
  def up
    admin_id = User.find_by(email: 'netpar@uke.gov.pl').id
    ExamFee.where(division_id: [13, 14, 15, 17, 22, 23]).all.each do |rec|
      rec.update_columns(valid_to: "2025-12-31", user_id: admin_id)
    end
  end

  def down
  end
end


    # exam_fees_data = [
    #    # [9 , "M", "świadectwo radioelektronika pierwszej klasy GMDSS", "G1E"], 
    #   # [10, "M", "świadectwo radioelektronika drugiej klasy GMDSS", "G2E"], 
    #   # [11, "M", "świadectwo ogólne operatora GMDSS", "GOC"], 
    #   # [12, "M", "świadectwo ograniczone operatora GMDSS", "ROC"], 
    #   [13, "M", "świadectwo operatora łączności dalekiego zasięgu LRC", "LRC", 175, 150 ], 
    #   [14, "M", "świadectwo operatora łączności bliskiego zasięgu SRC", "SRC", 175, 150 ],
    #   [15, "M", "świadectwo operatora radiotelefonisty VHF", "VHF", 175, 150 ],
    #   # [16, "M", "świadectwo operatora stacji nadbrzeżnej CSO", "CSO"], 
    #   [17, "M", "świadectwo operatora radiotelefonisty w służbie śródlądowej IWC", "IWC", 175, 150 ], 
    #   [22, "R", "egzamin do pozwolenia radiowego kategorii 1", "1", 50, 25 ],
    #   [23, "R", "egzamin do pozwolenia radiowego kategorii 3", "3", 25, 12.50 ]
    # ]
