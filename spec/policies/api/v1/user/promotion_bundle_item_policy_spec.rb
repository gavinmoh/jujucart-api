require 'rails_helper'

RSpec.describe Api::V1::User::PromotionBundleItemPolicy, type: :policy do
  let(:admin) { create(:user, role: 'admin') }
  let(:user) { create(:user, role: 'cashier') }
  let(:promotion_bundle_item) { create(:promotion_bundle_item) }

  subject { described_class }

  # permissions ".scope" do
  #   pending "add some examples to (or delete) #{__FILE__}"
  # end

  # permissions :show? do
  #   pending "add some examples to (or delete) #{__FILE__}"
  # end

  permissions :create? do
    it 'grants access if user is admin' do
      expect(subject).to permit(admin, promotion_bundle_item)
    end

    it 'denies access if user is not admin' do
      expect(subject).not_to permit(user, promotion_bundle_item)
    end
  end

  permissions :update? do
    it 'grants access if user is admin' do
      expect(subject).to permit(admin, promotion_bundle_item)
    end

    it 'denies access if user is not admin' do
      expect(subject).not_to permit(user, promotion_bundle_item)
    end
  end

  permissions :destroy? do
    it 'grants access if user is admin' do
      expect(subject).to permit(admin, promotion_bundle_item)
    end

    it 'denies access if user is not admin' do
      expect(subject).not_to permit(user, promotion_bundle_item)
    end
  end
end
