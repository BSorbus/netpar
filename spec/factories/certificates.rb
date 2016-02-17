FactoryGirl.define do
  factory :certificate do
    sequence(:number) { |n| "Cert No #{n}" }
    #number "Cert Nr."
    date_of_issue "2015-08-07"
    valid_thru "2015-08-07"
    certificate_status "N"
    exam nil
    division nil
    customer nil
    note "MyText"
    category "R"
    user nil

    trait :lot do
      number "Test C L-1"
      category 'L'
    end

    trait :mor do
      number "Test C M-1"
      category 'M'
    end

    trait :ra do
      number "Test C R-1"
      category 'R'
    end

  end


end
