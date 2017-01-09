module Features
  module SessionHelpers
    def sign_up_with(email, password, confirmation)
      visit new_user_registration_path
      # fill_in 'Email', with: email
      # fill_in 'Password', with: password
      # fill_in 'Password confirmation', :with => confirmation
      # click_button 'Sign up'

      fill_in User.human_attribute_name('email'), with: email
      fill_in User.human_attribute_name('password'), with: password
      fill_in User.human_attribute_name('password_confirmation'), with: confirmation
      click_button I18n.t('devise.registrations.form.new.button_submit')
    end

    def signin(email, password)
      visit new_user_session_path
      # fill_in 'Email', with: email
      # fill_in 'Password', with: password
      # click_button 'Sign in'
      fill_in User.human_attribute_name('email'), with: email
      fill_in User.human_attribute_name('password'), with: password
      click_button I18n.t('devise.sessions.form.new.button_submit')
    end
  end
end
