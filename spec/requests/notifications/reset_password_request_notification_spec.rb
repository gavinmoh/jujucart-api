require 'rails_helper'

RSpec.describe ResetPasswordRequestNotification do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:order) { create(:order) }

  it 'should send notification' do
    expect { ResetPasswordRequestNotification.deliver(user) }.not_to raise_error
  end

  it 'should be triggered when user request reset password' do
    post api_v1_user_passwords_url, params: { user: { email: user.email } }
    expect(enqueued_jobs.find { |job| job['job_class'] == 'DeliveryMethods::Macrokiosk' }).to be_present
  end
end