# Feature: Sign out
#   As a user
#   I want to sign out
#   So I can protect my account from unauthorized access
feature 'User Sign out', :devise do
  # Scenario: User signs out successfully
  #   Given I am signed in
  #   When I sign out
  #   Then I see a signed out message
  scenario '1. User signs out successfully' do
    user = FactoryBot.create(:user)
    signin(user.email, user.password)
    expect(page).to have_content I18n.t 'devise.sessions.user.signed_in'
    # click_link 'Sign out'
    click_link I18n.t 'devise.link_to.sign_out'
    expect(page).to have_content I18n.t 'devise.sessions.user.signed_out'
  end
end
