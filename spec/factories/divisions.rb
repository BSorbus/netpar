FactoryBot.define do
  factory :division do
    sequence(:name) { |n| "Name #{n}" }
    #name "Test Division"
    english_name "E Test Division"
    category "R"
    short_name "s n"
    number_prefix "p"
  end

end

