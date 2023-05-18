class DevisePreview < ActionMailer::Preview

  def reset_password_instructions
    user = FactoryBot.build(:user)
    Devise::Mailer.reset_password_instructions(user, "faketoken")
  end

end
