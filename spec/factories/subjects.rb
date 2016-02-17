FactoryGirl.define do
  factory :subject do
    sequence(:item) { |n| n }
    #item 1
    sequence(:name) { |n| "Subject name #{n}" }
    #name "MyString"
    division nil
    for_supplementary false
  end

end
