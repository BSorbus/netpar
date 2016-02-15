include Warden::Test::Helpers
Warden.test_mode!

# Feature: User edit
#   As a user
#   I want to edit my user profile
#   So I can change my email address
feature 'User edit', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: User changes email address
  #   Given I am signed in
  #   When I change my email address
  #   Then I see an account updated message
  scenario '1. User changes email address' do
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)
    visit edit_user_registration_path(user)
    #fill_in 'Email', :with => 'newemail@uke.gov.pl'
    #fill_in 'Current password', :with => user.password
    #click_button 'Save'
    fill_in User.human_attribute_name('email'), :with => 'newemail@uke.gov.pl'
    fill_in User.human_attribute_name('current_password'), :with => user.password
    click_button I18n.t('devise.registrations.form.edit.button_submit')
    #txts = [I18n.t( 'devise.registrations.updated'), I18n.t( 'devise.registrations.update_needs_confirmation')]
    #expect(page).to have_content(/.*#{txts[0]}.*|.*#{txts[1]}.*/)
    expect(page).to have_content I18n.t( 'devise.registrations.update_needs_confirmation')
  end

  # Scenario: User changes email address to no UKE Domain
  #   Given I am signed in
  #   When I change my email address
  #   Then I see an account updated message
  scenario '2. User changes email address no UKE domain' do
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)
    visit edit_user_registration_path(user)
    #fill_in 'Email', :with => 'newemail@nouke.domain.com'
    #fill_in 'Current password', :with => user.password
    #click_button 'Save'
    fill_in User.human_attribute_name('email'), with: 'newemail@nouke.domain.com'
    fill_in User.human_attribute_name('current_password'), with: user.password
    click_button I18n.t('devise.registrations.form.edit.button_submit')
    #expect(page).to have_content 'Edit account'
    #expect(page).to have_content 'Email is invalid'
    expect(page).to have_content 'Test User'
    #expect(page).to have_content 'Email is invalid'
    expect(page).to have_content 'Email jest nieprawidłowe'
  end

  # Scenario: User cannot edit another user's profile
  #   Given I am signed in
  #   When I try to edit another user's profile
  #   Then I see my own 'edit profile' page
  scenario "3. User cannot edit another user's profile", :me do
    me = FactoryGirl.create(:user)
    other = FactoryGirl.create(:user, email: 'other@uke.gov.pl', authentication_token: 'other12345678')
    login_as(me, :scope => :user)
    visit edit_user_registration_path(other)
    #expect(page).to have_content 'Edit account'
    #expect(page).to have_field('Email', with: me.email)
    expect(page).to have_content 'Test User'
    expect(page).to have_field(User.human_attribute_name('email'), with: me.email)
  end

end
