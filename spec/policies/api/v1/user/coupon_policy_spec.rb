require 'rails_helper'

RSpec.describe Api::V1::User::CouponPolicy, type: :policy do
  let(:user) { create(:user, role: 'cashier') }
  let(:admin) { create(:user, role: 'admin') }
  let(:coupon) { create(:coupon) }

  subject { described_class }

  # permissions ".scope" do
  #   pending "add some examples to (or delete) #{__FILE__}"
  # end

  # permissions :show? do
  #   pending "add some examples to (or delete) #{__FILE__}"
  # end

  permissions :create? do
    it "denies access if user is not admin" do
      expect(subject).not_to permit(user, coupon)
    end

    it "grants access if user is admin" do
      expect(subject).to permit(admin, coupon)
    end
  end

  permissions :update? do
    it "denies access if user is not admin" do
      expect(subject).not_to permit(user, coupon)
    end

    it "grants access if user is admin" do
      expect(subject).to permit(admin, coupon)
    end
  end

  permissions :destroy? do
    it "denies access if user is not admin" do
      expect(subject).not_to permit(user, coupon)
    end

    it "grants access if user is admin" do
      expect(subject).to permit(admin, coupon)
    end
  end
end
