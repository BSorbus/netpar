include Warden::Test::Helpers
Warden.test_mode!

# Feature: User index page
#   As a user
#   I want to see a list of users
#   So I can see who has registered
feature 'User Index pages', :devise do
  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Simple User cannot listed Users
  #   Given I am signed in
  #   When I visit the user index page
  #   Then I see error message
  scenario '1. Simple User cannot listed Users' do
    # user = FactoryGirl.create(:user, :admin)
    # login_as(user, scope: :user)
    # visit users_path
    # expect(page).to not have_content user.email
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    visit users_path
    expect(page).to have_content I18n.t 'pundit.user_policy.index?'
  end

  # Scenario: Simple User cannot listed Users
  #   Given I am signed in
  #   When I visit the work index page
  #   Then I see error message
  scenario '2. Simple User cannot listed Works' do
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    visit works_path
    expect(page).to have_content I18n.t 'pundit.work_policy.index?'
  end

  # Scenario: Simple User cannot listed Roles
  #   Given I am signed in
  #   When I visit the role index page
  #   Then I see error message
  scenario '3. Simple User cannot listed Roles' do
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    visit roles_path
    expect(page).to have_content I18n.t 'pundit.role_policy.index?'
  end

  # Scenario: Simple User cannot listed Departments
  #   Given I am signed in
  #   When I visit the department index page
  #   Then I see error message
  scenario '4. Simple User cannot listed Departments' do
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    visit departments_path
    expect(page).to have_content I18n.t 'pundit.department_policy.index?'
  end

  # Scenario: Simple User cannot listed Customers
  #   Given I am signed in
  #   When I visit the customer index page
  #   Then I see error message
  scenario '5. Simple User cannot listed Customers' do
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    visit customers_path
    expect(page).to have_content I18n.t 'pundit.customer_policy.index?'
  end

  # Scenario: Simple User cannot listed Exams category L
  #   Given I am signed in
  #   When I visit the exam category L index page
  #   Then I see error message
  scenario '6. Simple User cannot listed LOT Exams' do
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    visit exams_path(category_service: 'l')
    expect(page).to have_content I18n.t 'pundit.exam_policy.index_l?'
  end

  # Scenario: Simple User cannot listed Exams category M
  #   Given I am signed in
  #   When I visit the exam category M index page
  #   Then I see error message
  scenario '7. Simple User cannot listed MOR Exams' do
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    visit exams_path(category_service: 'm')
    expect(page).to have_content I18n.t 'pundit.exam_policy.index_m?'
  end

  # Scenario: Simple User cannot listed Exams category R
  #   Given I am signed in
  #   When I visit the exam category R index page
  #   Then I see error message
  scenario '8. Simple User cannot listed RA Exams' do
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    visit exams_path(category_service: 'r')
    expect(page).to have_content I18n.t 'pundit.exam_policy.index_r?'
  end

  # Scenario: Simple User cannot listed Certificates category L
  #   Given I am signed in
  #   When I visit the certificate category L index page
  #   Then I see error message
  scenario '9. Simple User cannot listed LOT Certificates' do
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    visit certificates_path(category_service: 'l')
    expect(page).to have_content I18n.t 'pundit.certificate_policy.index_l?'
  end

  # Scenario: Simple User cannot listed Certificates category M
  #   Given I am signed in
  #   When I visit the certificate category M index page
  #   Then I see error message
  scenario '10. Simple User cannot listed MOR Certificates' do
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    visit certificates_path(category_service: 'm')
    expect(page).to have_content I18n.t 'pundit.certificate_policy.index_m?'
  end

  # Scenario: Simple User cannot listed Certificates category R
  #   Given I am signed in
  #   When I visit the certificate category R index page
  #   Then I see error message
  scenario '11. Simple User cannot listed RA Certificates' do
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    visit certificates_path(category_service: 'r')
    expect(page).to have_content I18n.t 'pundit.certificate_policy.index_r?'
  end
end
