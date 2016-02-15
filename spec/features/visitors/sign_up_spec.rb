# Feature: Sign up
#   As a visitor
#   I want to sign up
#   So I can visit protected areas of the site
feature 'Sign Up', :devise do

  # Scenario: Visitor can sign up with valid email address and password
  #   Given I am not signed in
  #   When I sign up with a valid email address and password
  #   Then I see a successful sign up message
  scenario '1. visitor can sign up with valid email address and password' do
    sign_up_with('test@uke.gov.pl', 'Please123!', 'Please123!')

    #txts = [I18n.t( 'devise.registrations.signed_up'), I18n.t( 'devise.registrations.signed_up_but_unconfirmed')]
    #expect(page).to have_content(/.*#{txts[0]}.*|.*#{txts[1]}.*/)
    # if not confirmation options
    #expect(page).to have_content I18n.t( 'devise.registrations.signed_up')
    expect(page).to have_content I18n.t( 'devise.registrations.signed_up_but_unconfirmed')
  end

  # Scenario: Visitor cannot sign up with invalid email address
  #   Given I am not signed in
  #   When I sign up with an invalid email address
  #   Then I see an invalid email message
  scenario '2. visitor cannot sign up with invalid email address' do
    sign_up_with('bogus', 'Please123!', 'Please123!')
    #expect(page).to have_content 'Email is invalid'
    expect(page).to have_content 'Email jest nieprawidłowe'
  end

  # Scenario: Visitor cannot sign up with invalid email domain address
  #   Given I am not signed in
  #   When I sign up with an invalid email domanin address
  #   Then I see an invalid email message
  scenario '3. visitor cannot sign up with invalid email address' do
    sign_up_with('test@nouke.domain.com', 'Please123!', 'Please123!')
    #expect(page).to have_content 'Email is invalid'
    expect(page).to have_content 'Email jest nieprawidłowe'
  end

  # Scenario: Visitor cannot sign up without password
  #   Given I am not signed in
  #   When I sign up without a password
  #   Then I see a missing password message
  scenario '4. visitor cannot sign up without password' do
    sign_up_with('test@uke.gov.pl', '', '')
    #expect(page).to have_content "Password can't be blank"
    expect(page).to have_content "Hasło nie może być puste"
  end

  # Scenario: Visitor cannot sign up without password confirmation
  #   Given I am not signed in
  #   When I sign up without a password confirmation
  #   Then I see a missing password confirmation message
  scenario '5. visitor cannot sign up without password confirmation' do
    sign_up_with('test@uke.gov.pl', 'Please123!', '')
    #expect(page).to have_content "Password confirmation doesn't match"
    expect(page).to have_content "Potwórz hasło nie zgadza się z potwierdzeniem"
  end

  # Scenario: Visitor cannot sign up with mismatched password and confirmation
  #   Given I am not signed in
  #   When I sign up with a mismatched password confirmation
  #   Then I should see a mismatched password message
  scenario '6. visitor cannot sign up with mismatched password and confirmation' do
    sign_up_with('test@uke.gov.pl', 'Please123!', 'mismatch')
    #expect(page).to have_content "Password confirmation doesn't match"
    expect(page).to have_content "Potwórz hasło nie zgadza się z potwierdzeniem"
  end

  # Scenario: Visitor cannot sign up with a short password
  #   Given I am not signed in
  #   When I sign up with a short password
  #   Then I see a 'too short password' message
  scenario '7. visitor cannot sign up with a short password' do
    sign_up_with('test@uke.gov.pl', 'Pl1!', 'Pl1!')
    expect(page).to have_content "Hasło jest za krótkie (przynajmniej 8 znaków)"
  end

  # Scenario: visitor cannot sign up without big letter in password
  #   Given I am not signed in
  #   When I sign up with a short password
  #   Then I see a 'too short password' message
  scenario '8. visitor cannot sign up without big letter in password' do
    sign_up_with('test@uke.gov.pl', 'please123!', 'please123!')
    #expect(page).to have_content "Password is too short"
    expect(page).to have_content I18n.t('errors.messages.password_format')
  end

  # Scenario: visitor cannot sign up without digit in password
  #   Given I am not signed in
  #   When I sign up with a short password
  #   Then I see a 'too short password' message
  scenario '9. visitor cannot sign up without digit in password' do
    sign_up_with('test@uke.gov.pl', 'PleasePlease!', 'PleasePlease!')
    #expect(page).to have_content "Password is too short"
    expect(page).to have_content I18n.t('errors.messages.password_format')
  end

  # Scenario: visitor cannot sign up without special chart in password
  #   Given I am not signed in
  #   When I sign up with a short password
  #   Then I see a 'too short password' message
  scenario '10. visitor cannot sign up without special chart in password' do
    sign_up_with('test@uke.gov.pl', 'Please123', 'Please123')
    #expect(page).to have_content "Password is too short"
    expect(page).to have_content I18n.t('errors.messages.password_format')
  end

end
