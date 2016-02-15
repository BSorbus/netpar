FactoryGirl.define do
  factory :role do
    name "Test Role"
    activities ["test:index"]

    #trait :admin do
    #  role 'admin'
    #end
    
  end

end

