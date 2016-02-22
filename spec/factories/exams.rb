FactoryGirl.define do
  factory :exam do
    sequence(:number) { |n| "Exam No #{n}" }
    #number "E number"
    date_exam "2015-08-07"
    place_exam "place_exam"
    chairman "chairman"
    secretary "secretary"
    category "R"
    note "note"
    user nil

    trait :lot do
      category 'L'
    end

    trait :mor do
      category 'M'
    end

    trait :ra do
      category 'R'
    end

  end

end
