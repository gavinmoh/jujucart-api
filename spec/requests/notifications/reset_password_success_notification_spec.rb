require 'rails_helper'

RSpec.describe ResetPasswordSuccessNotification do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }

  it 'should send notification' do
    expect { ResetPasswordSuccessNotification.deliver(user) }.not_to raise_error
  end

  it 'should be triggered when user successfully reset password' do
    put api_v1_user_passwords_url, params: { user: { reset_password_token: user.send_reset_password_instructions, password: "password123", password_confirmation: "password123" } }
    expect(enqueued_jobs.find { |job| job['job_class'] == 'DeliveryMethods::Macrokiosk' }).to be_present
  end
end