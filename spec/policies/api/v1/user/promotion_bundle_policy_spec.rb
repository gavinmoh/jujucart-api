require 'rails_helper'

RSpec.describe Api::V1::User::PromotionBundlePolicy, type: :policy do
  let(:user) { create(:user, role: 'cashier') }
  let(:admin) { create(:user, role: 'admin') }
  let(:promotion_bundle) { create(:promotion_bundle) }

  subject { described_class }

  # permissions ".scope" do
  #   pending "add some examples to (or delete) #{__FILE__}"
  # end

  # permissions :show? do
  #   pending "add some examples to (or delete) #{__FILE__}"
  # end

  permissions :create? do
    it 'grants access if user is admin' do
      expect(subject).to permit(admin, promotion_bundle)
    end

    it 'denies access if user is not admin' do
      expect(subject).not_to permit(user, promotion_bundle)
    end
  end

  permissions :update? do
    it 'grants access if user is admin' do
      expect(subject).to permit(admin, promotion_bundle)
    end

    it 'denies access if user is not admin' do
      expect(subject).not_to permit(user, promotion_bundle)
    end
  end

  permissions :destroy? do
    it 'grants access if user is admin' do
      expect(subject).to permit(admin, promotion_bundle)
    end

    it 'denies access if user is not admin' do
      expect(subject).not_to permit(user, promotion_bundle)
    end
  end
end
