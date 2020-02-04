class AddCorrectionToExamFees < ActiveRecord::Migration
  def up
    ExamFee.find_or_create_by!(esod_category: 42, division: Division.find_by(short_name: 'G1E')) do |ef|
      ef.price = 100.00
      ef.save!
    end
    ExamFee.find_or_create_by!(esod_category: 42, division: Division.find_by(short_name: 'G2E')) do |ef|
      ef.price = 100.00
      ef.save!
    end
    ExamFee.find_or_create_by!(esod_category: 42, division: Division.find_by(short_name: 'GOC')) do |ef|
      ef.price = 80.00
      ef.save!
    end
    ExamFee.find_or_create_by!(esod_category: 42, division: Division.find_by(short_name: 'ROC')) do |ef|
      ef.price = 70.00
      ef.save!
    end
    ExamFee.find_or_create_by!(esod_category: 42, division: Division.find_by(short_name: 'CSO')) do |ef|
      ef.price = 75.00
      ef.save!
    end
    ExamFee.find_or_create_by!(esod_category: 42, division: Division.find_by(short_name: 'IWC')) do |ef|
      ef.price = 50.00
      ef.save!
    end
    ExamFee.find_or_create_by!(esod_category: 42, division: Division.find_by(short_name: 'LRC')) do |ef|
      ef.price = 60.00
      ef.save!
    end
    ExamFee.find_or_create_by!(esod_category: 42, division: Division.find_by(short_name: 'SRC')) do |ef|
      ef.price = 50.00
      ef.save!
    end
    ExamFee.find_or_create_by!(esod_category: 42, division: Division.find_by(short_name: 'VHF')) do |ef|
      ef.price = 40.00
      ef.save!
    end

    ExamFee.find_or_create_by!(esod_category: 42, division: Division.find_by(short_name: 'A')) do |ef|
      ef.price = 25.00
      ef.save!
    end
    ExamFee.find_or_create_by!(esod_category: 42, division: Division.find_by(short_name: 'C')) do |ef|
      ef.price = 12.50
      ef.save!
    end
  end

  def down

  end
end
