require 'rails_helper'

RSpec.describe OrderCoupon, type: :model do
  describe 'associations' do
    it { should belong_to(:order) }
    it { should belong_to(:coupon).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:code) }
  end

  describe 'callbacks' do
    describe 'before_validation' do
      describe '#upcase_code' do
        let(:order_coupon) { build(:order_coupon, code: 'abc') }

        it 'upcases the code' do
          order_coupon.valid?
          expect(order_coupon.code).to eq('ABC')
        end
      end

      describe '#set_coupon' do
        let(:coupon) { create(:coupon) }
        let(:order) { create(:order) }
        let(:order_coupon) { build(:order_coupon, order: order, coupon: nil) }

        it 'sets the coupon' do
          order_coupon.code = coupon.code
          order_coupon.save
          expect(order_coupon.coupon).to eq(coupon)
        end
      end
    end

    describe 'before_save' do
      it 'calculate discount' do
        order = create(:order, status: 'pending')
        create_list(:line_item, 2, order: order)
        coupon = create(:coupon, discount_by: 'percentage_discount', discount_percentage: 10)
        order_coupon = build(:order_coupon, coupon: coupon, code: coupon.code, order: order)
        calculated_discount = order.subtotal * (coupon.discount_percentage / 100.0)
        expect do
          order_coupon.save
        end.to change { order_coupon.discount_cents }.from(0).to(calculated_discount.cents)
      end
    end

    describe 'after_commit' do
      it 'update order price' do
        order = create(:order, status: 'pending')
        create_list(:line_item, 2, order: order)
        coupon = create(:coupon, discount_by: 'percentage_discount', discount_percentage: 10)
        create(:order_coupon, coupon: coupon, code: coupon.code, order: order)
        calculated_discount = order.subtotal * (coupon.discount_percentage / 100.0)
        order.reload
        expect(order.discount_cents).to eq(calculated_discount.cents)
      end
    end
  end


end
