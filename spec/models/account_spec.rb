require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
    it { is_expected.to have_many(:notifications).dependent(:destroy).with_foreign_key(:recipient_id) }
    it { is_expected.to have_many(:notification_tokens).dependent(:destroy).with_foreign_key(:recipient_id) }
  end

  describe 'allow same email for different type' do
    let(:email) { Faker::Internet.email }

    before do
      create(:admin, email: email)
    end

    it { expect(build(:user, email: email)).to be_valid }
    it { expect{ create(:user, email: email) }.not_to raise_error }
    it { expect{ create(:admin, email: email) }.to raise_error(ActiveRecord::RecordInvalid) }
  end

  describe 'methods' do
    describe '#active_for_authentication?' do
      let(:account) { build(:admin, active: active) }

      subject { account.active_for_authentication? }

      context 'when account is active' do
        let(:active) { true }

        it { is_expected.to be_truthy }
      end

      context 'when account is not active' do
        let(:active) { false }

        it { is_expected.to be_falsey }
      end
    end

    describe '#badge_count' do
      let(:user) { create(:user) }
      let!(:unread) { create(:notification, recipient: user) }
      let!(:random_notification) { create(:notification) }
      let!(:read) { create(:notification, recipient: user, read_at: Time.current) }

      it 'should return unread notification count' do
        expect(user.badge_count).to eq 1
      end
    end
  end
end
