include Warden::Test::Helpers
Warden.test_mode!

# Feature: User index page
#   As a user
#   I want to see a list of users
#   So I can see who has registered
feature '5. Index pages', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: User listed on index page
  #   Given I am signed in
  #   When I visit the user index page
  #   Then I see my own email address
  scenario '5.1. users_path - Simple User cannot listed Users' do
    #user = FactoryGirl.create(:user, :admin)
    #login_as(user, scope: :user)
    #visit users_path
    #expect(page).to not have_content user.email
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    visit users_path
    expect(page).to have_content I18n.t 'pundit.user_policy.index?'
  end

  scenario '5.2. roles_path - Simple User cannot listed Roles' do
    #user = FactoryGirl.create(:user, :admin)
    #login_as(user, scope: :user)
    #visit users_path
    #expect(page).to not have_content user.email
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    visit roles_path
    expect(page).to have_content I18n.t 'pundit.role_policy.index?'
  end

end
