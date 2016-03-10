FactoryGirl.define do
  factory :esod_case do
    sequence(:nrid) { |n| n }
    sequence(:znak) { |n| "znak#{n}" }
    sequence(:znak_sprawy_grupujacej) { |n| "znak_sprawy_sprawy_grupujacej#{n}" }
    symbol_jrwa "jrwa" #5410 - LOT, 5411 - MOR, 5412 - RA
    sequence(:tytul) { |n| "Tytul#{n}" }
    termin_realizacji "2016-03-02"
    identyfikator_kategorii_sprawy 1
    adnotacja "adnotacja"
    identyfikator_stanowiska_referenta 1
#    czy_otwarta false
    esod_created_at "2016-03-02 12:34:20.546257"
    esod_updated_et "2016-03-02 12:34:20.546257"

    trait :lot do
      symbol_jrwa '5410'
    end

    trait :mor do
      symbol_jrwa '5411'
    end

    trait :ra do
      symbol_jrwa '5412'
    end

  end
end
