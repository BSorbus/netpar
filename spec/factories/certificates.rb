FactoryBot.define do
  factory :certificate do
    sequence(:number) { |n| "Cert No #{n}" }
    #number "Cert Nr."
    date_of_issue "2015-08-07"
    valid_thru "2015-08-07"
    canceled false
    exam nil
    division nil
    customer nil
    note "MyText"
    category "R"
    user nil
    esod_category 1

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
