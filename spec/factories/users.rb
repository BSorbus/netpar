FactoryGirl.define do
  factory :user do
    name "Test User"
    email "test@uke.gov.pl"
    password "Please123!"
    authentication_token "123456789!"

    # add if Devise confirmable
    #after(:build) do |u|
    #  u.confirm!
    #  u.skip_confirmation_notification!
    #end
    # or
    before(:create) {|user| user.skip_confirmation! }

    trait :as_certificate_l_observer do
      after(:create) do |user|
        role = CreateRoleService.new.certificate_l_observer
        user.roles << role
      end
    end

    trait :as_certificate_l_manager do
      after(:create) do |user|
        role = CreateRoleService.new.certificate_l_manager
        user.roles << role
      end
    end

    trait :as_certificate_m_observer do
      after(:create) do |user|
        role = CreateRoleService.new.certificate_m_observer
        user.roles << role
      end
    end

    trait :as_certificate_m_manager do
      after(:create) do |user|
        role = CreateRoleService.new.certificate_m_manager
        user.roles << role
      end
    end

    trait :as_certificate_r_observer do
      after(:create) do |user|
        role = CreateRoleService.new.certificate_r_observer
        user.roles << role
      end
    end

    trait :as_certificate_r_manager do
      after(:create) do |user|
        role = CreateRoleService.new.certificate_r_manager
        user.roles << role
      end
    end

    trait :as_customer_manager do
      after(:create) do |user|
        role = CreateRoleService.new.customer_manager
        user.roles << role
      end
    end

    trait :as_customer_observer do
      after(:create) do |user|
        role = CreateRoleService.new.customer_observer
        user.roles << role
      end
    end

    trait :as_department_manager do
      after(:create) do |user|
        role = CreateRoleService.new.department_manager
        user.roles << role
      end
    end

    trait :as_department_observer do
      after(:create) do |user|
        role = CreateRoleService.new.department_observer
        user.roles << role
      end
    end

    trait :as_exam_l_observer do
      after(:create) do |user|
        role = CreateRoleService.new.exam_l_observer
        user.roles << role
      end
    end

    trait :as_exam_l_manager do
      after(:create) do |user|
        role = CreateRoleService.new.exam_l_manager
        user.roles << role
      end
    end

    trait :as_exam_m_observer do
      after(:create) do |user|
        role = CreateRoleService.new.exam_m_observer
        user.roles << role
      end
    end

    trait :as_exam_m_manager do
      after(:create) do |user|
        role = CreateRoleService.new.exam_m_manager
        user.roles << role
      end
    end

    trait :as_exam_r_observer do
      after(:create) do |user|
        role = CreateRoleService.new.exam_r_observer
        user.roles << role
      end
    end

    trait :as_exam_r_manager do
      after(:create) do |user|
        role = CreateRoleService.new.exam_r_manager
        user.roles << role
      end
    end

    trait :as_examination_l_observer do
      after(:create) do |user|
        role = CreateRoleService.new.examination_l_observer
        user.roles << role
      end
    end

    trait :as_examination_l_manager do
      after(:create) do |user|
        role = CreateRoleService.new.examination_l_manager
        user.roles << role
      end
    end

    trait :as_examination_m_observer do
      after(:create) do |user|
        role = CreateRoleService.new.examination_m_observer
        user.roles << role
      end
    end

    trait :as_examination_m_manager do
      after(:create) do |user|
        role = CreateRoleService.new.examination_m_manager
        user.roles << role
      end
    end

    trait :as_examination_r_observer do
      after(:create) do |user|
        role = CreateRoleService.new.examination_r_observer
        user.roles << role
      end
    end

    trait :as_examination_r_manager do
      after(:create) do |user|
        role = CreateRoleService.new.examination_r_manager
        user.roles << role
      end
    end

    trait :as_role_manager do
      after(:create) do |user|
        role = CreateRoleService.new.role_manager
        user.roles << role
      end
    end

    trait :as_role_observer do
      after(:create) do |user|
        role = CreateRoleService.new.role_observer
        user.roles << role
      end
    end

    trait :as_user_manager do
      after(:create) do |user|
        role = CreateRoleService.new.user_manager
        user.roles << role
      end
    end

    trait :as_user_observer do
      after(:create) do |user|
        role = CreateRoleService.new.user_observer
        user.roles << role
      end
    end


  end


  factory :user_domain_nouke do
    name "Test NoUkeUser"
    email "test@nouke.domain.com"
    password "Please123!"
    authentication_token "987654321!"

    #trait :admin do
    #  role 'admin'
    #end

    # add if Devise confirmable
    before(:create) {|user| user.skip_confirmation! }

  end



end

