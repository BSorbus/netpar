class UpdateExamFeePrices < ActiveRecord::Migration

  DIVISION_R_1 = 22
  DIVISION_R_3 = 23

  EGZAMIN = 41
  POPRAWKOWY = 42

  OLD_DATE_VALID_FROM = '2026-01-01'
  OLD_DATE_VALID_TO = '2026-04-30'

  NEW_DATE_VALID_FROM = '2026-05-01'

  def up
    admin_id = User.find_by(email: 'netpar@uke.gov.pl').id
    max_id = ExamFee.maximum(:id)


    exam_fees_update_array = [
      { division_id: DIVISION_R_1, esod_category: EGZAMIN,    valid_from: OLD_DATE_VALID_FROM, price: 150, price_under18: 75, user_id: admin_id},
      { division_id: DIVISION_R_1, esod_category: POPRAWKOWY, valid_from: OLD_DATE_VALID_FROM, price: 75,  price_under18: 35, user_id: admin_id },
      { division_id: DIVISION_R_3, esod_category: EGZAMIN,    valid_from: OLD_DATE_VALID_FROM, price: 150, price_under18: 75, user_id: admin_id },
      { division_id: DIVISION_R_3, esod_category: POPRAWKOWY, valid_from: OLD_DATE_VALID_FROM, price: 75,  price_under18: 35, user_id: admin_id },
    ]

    exam_fees_update_array.each do |element|
      element_for_find = element.except(:price, :price_under18, :user_id)
      exam_fee = ExamFee.find_by(element_for_find)

      if exam_fee.present?
        # update OLD
        exam_fee.valid_to = OLD_DATE_VALID_TO
        exam_fee.price_under18 = exam_fee.price
        exam_fee.save
        exam_fee.works.create!(
          trackable_id: exam_fee.id,
          trackable_type: "ExamFee",
          trackable_url: "/exam_fees/#{exam_fee.id}", 
          action: :update, 
          user_id: admin_id, 
          parameters: exam_fee.attributes.to_json
        )

        # NEW
        max_id = max_id + 1
        exam_fee_new = ExamFee.new(element)
        exam_fee_new.id = max_id
        exam_fee_new.valid_from = NEW_DATE_VALID_FROM
        exam_fee_new.save

        exam_fee_new.works.create!(
          trackable_id: exam_fee_new.id,
          trackable_type: "ExamFee",
          trackable_url: "/exam_fees/#{exam_fee_new.id}", 
          action: :create, 
          user_id: admin_id, 
          parameters: exam_fee_new.attributes.to_json
        )

      end

    end


  end

  def down
  end
end
