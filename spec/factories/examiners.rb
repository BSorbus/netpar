FactoryGirl.define do
  #sequence(:name) { |n| "Example name #{n}" }

  factory :examiner do
    sequence(:name) { |n| "Example name #{n}" }
    #name "E name"
    exam nil
  end
end
