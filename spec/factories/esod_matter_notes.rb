FactoryGirl.define do
  factory :esod_matter_note, class: 'Esod::MatterNote' do
    esod_matter nil
    nrid 1
    tytul 'MyString'
    tresc 'MyString'
  end
end
