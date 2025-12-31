class AddExamFeeDates < ActiveRecord::Migration
  def up
    admin_id = User.find_by(email: 'netpar@uke.gov.pl').id
    max_id = ExamFee.maximum(:id)

    exam_fees_data = [
      # [9 , "M", "świadectwo radioelektronika pierwszej klasy GMDSS", "G1E"], 
      # [10, "M", "świadectwo radioelektronika drugiej klasy GMDSS", "G2E"], 
      # [11, "M", "świadectwo ogólne operatora GMDSS", "GOC"], 
      # [12, "M", "świadectwo ograniczone operatora GMDSS", "ROC"], 
      [13, "M", "świadectwo operatora łączności dalekiego zasięgu LRC", "LRC", 175, 150 ], 
      [14, "M", "świadectwo operatora łączności bliskiego zasięgu SRC", "SRC", 175, 150 ],
      [15, "M", "świadectwo operatora radiotelefonisty VHF", "VHF", 175, 150 ],
      # [16, "M", "świadectwo operatora stacji nadbrzeżnej CSO", "CSO"], 
      [17, "M", "świadectwo operatora radiotelefonisty w służbie śródlądowej IWC", "IWC", 175, 150 ], 
      [22, "R", "egzamin do pozwolenia radiowego kategorii 1", "1", 50, 25 ],
      [23, "R", "egzamin do pozwolenia radiowego kategorii 3", "3", 25, 12.50 ]
    ]

    exam_fees_data.each do |ef|

      max_id = max_id + 1
      exam_fee = ExamFee.create!(
        id: max_id, 
        division_id: ef[0],
        esod_category: 41,
        price: ef[4],
        valid_from: '2026-01-01',
        user_id: admin_id
        )

      exam_fee.works.create!(
        trackable_id: exam_fee.id,
        trackable_type: "ExamFee",
        trackable_url: "/exam_fees/#{exam_fee.id}", 
        action: :create, 
        user_id: admin_id, 
        parameters: exam_fee.attributes.to_json)


      max_id = max_id + 1
      exam_fee = ExamFee.create!(
        id: max_id, 
        division_id: ef[0],
        esod_category: 42,
        price: ef[5],
        valid_from: '2026-01-01',
        user_id: admin_id
        )
      exam_fee.works.create!(
        trackable_id: exam_fee.id,
        trackable_type: "ExamFee",
        trackable_url: "/exam_fees/#{exam_fee.id}", 
        action: :create, 
        user_id: admin_id, 
        parameters: exam_fee.attributes.to_json)

    end

  end

  def down
  end
end
