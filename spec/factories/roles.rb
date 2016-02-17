FactoryGirl.define do
  factory :role do
    sequence(:name) { |n| "Role Name #{n}" }
    #name "Test Role"
    activities ["test:index"]

    #trait :admin do
    #  role 'admin'
    #end
    
  end

end

