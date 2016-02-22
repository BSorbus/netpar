FactoryGirl.define do
  factory :citizenship do
    sequence(:name) { |n| "Name#{n}" }
    #name "Test Citizenship"
    #short "TC"
    sequence(:short) { |n| "S#{n}" }
  end

end
