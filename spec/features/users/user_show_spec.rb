include Warden::Test::Helpers
Warden.test_mode!

# Feature: User profile page
#   As a user
#   I want to visit my user profile page
#   So I can see my personal account data
feature 'User profile page', :devise do
  after(:each) do
    Warden.test_reset!
  end

  # Scenario: User sees own profile
  #   Given I am signed in
  #   When I visit the user profile page
  #   Then I see my own email address
  scenario '1. User sees own profile' do
    user = FactoryBot.create(:user)
    login_as(user, scope: :user)
    visit user_path(user)
    expect(page).to have_content 'Test User'
    # expect(page).to have_content user.email
  end

  # Scenario: User cannot see another user's profile
  #   Given I am signed in
  #   When I visit another user's profile
  #   Then I see an 'access denied' message
  scenario "2. Simple User cannot see another user's profile" do
    me = FactoryBot.create(:user)
    other = FactoryBot.create(:user, email: 'other@uke.gov.pl', authentication_token: 'other12345678')
    login_as(me, scope: :user)
    Capybara.current_session.driver.header 'Referer', root_path
    visit user_path(other)
    # expect(page).to have_content 'SECURITY: Access denied!'
    expect(page).to have_content I18n.t 'pundit.user_policy.show?'
  end
end
