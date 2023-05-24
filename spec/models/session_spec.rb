require 'rails_helper'

RSpec.describe Session, type: :model do
  describe 'associations' do
    it { should belong_to(:account) }
  end

  describe 'validations' do
    it { should have_secure_token(:token) }
  end

  describe 'methods' do
    context '#revoke!' do
      it 'should revoke the session' do
        session = create(:session)
        session.revoke!
        expect(session.revoked_at).to_not be_nil
      end
    end

    context '#revoked?' do
      it 'should return true if session is revoked' do
        session = create(:session, revoked_at: Time.current)
        expect(session.revoked?).to be_truthy
      end

      it 'should return false if session is not revoked' do
        session = create(:session)
        expect(session.revoked?).to be_falsey
      end
    end

    context '#expired?' do
      it 'should return true if session is expired' do
        session = create(:session, expired_at: Time.current - 1.day)
        expect(session.expired?).to be_truthy
      end

      it 'should return false if session is not expired' do
        session = create(:session, expired_at: Time.current + 1.day)
        expect(session.expired?).to be_falsey
      end
    end
  end
end
