FactoryGirl.define do
  factory :citizenship do
    sequence(:name) { |n| "Name #{n}" }
    #name "Test Citizenship"
    short "TC"
  end

end
