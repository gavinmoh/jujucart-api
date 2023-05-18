require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code).case_insensitive }
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:redemption_limit).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:discount_by) }
    it { should validate_presence_of(:coupon_type) }
    it { should validate_presence_of(:discount_on) }

    context 'order_types' do
      let(:subject) { build(:coupon) }
      it 'should validate order_types_must_have_at_least_one' do
        subject.order_types = []
        expect(subject).to_not be_valid
      end

      it 'should validate order_types_must_be_valid' do
        subject.order_types = ['invalid']
        expect(subject).to_not be_valid
        subject.order_types = ['delivery', 'pickup', 'pos']
        expect(subject).to be_valid
      end
    end

    context 'when discount_by is price_discount' do
      let(:subject) { build(:coupon, discount_by: 'price_discount') }
      it 'should validate discount_price' do
        subject.discount_price_cents = 0
        expect(subject).to_not be_valid        
      end
    end

    context 'when discount_by is percentage_discount' do
      let(:subject) { build(:coupon, discount_by: 'percentage_discount') }
      it { should validate_numericality_of(:discount_percentage).is_less_than_or_equal_to(100) }
      it { should validate_numericality_of(:discount_percentage).is_greater_than(0) }
      it 'should not allow nil for discount_percentage' do
        subject.discount_percentage = nil
        expect(subject).to_not be_valid
      end
    end
  end

  describe 'scope' do
    let!(:active_coupon) { create(:coupon, start_at: Time.zone.now - 1.day, end_at: Time.zone.now + 1.day) }
    let!(:scheduled_coupon) { create(:coupon, start_at: Time.zone.now + 1.day, end_at: Time.zone.now + 2.days) }
    let!(:expired_coupon) { create(:coupon, start_at: Time.zone.now - 2.days, end_at: Time.zone.now - 1.day) }
    
    context 'active' do
      it 'should return active coupons' do
        expect(Coupon.active).to include(active_coupon)
        expect(Coupon.active).to_not include(scheduled_coupon)
        expect(Coupon.active).to_not include(expired_coupon)
      end
    end

    context 'scheduled' do
      it 'should return scheduled coupons' do
        expect(Coupon.scheduled).to_not include(active_coupon)
        expect(Coupon.scheduled).to include(scheduled_coupon)
        expect(Coupon.scheduled).to_not include(expired_coupon)
      end
    end

    context 'expired' do
      it 'should return expired coupons' do
        expect(Coupon.expired).to_not include(active_coupon)
        expect(Coupon.expired).to_not include(scheduled_coupon)
        expect(Coupon.expired).to include(expired_coupon)
      end
    end
  end

  describe 'methods' do
    context 'maximum_capped?' do
      let(:subject) { build(:coupon) }
      it 'should return true if maximum_cap_cents > 0' do
        subject.maximum_cap_cents = 100
        expect(subject.maximum_capped?).to eq(true)
      end

      it 'should return false if maximum_cap_cents <= 0' do
        subject.maximum_cap_cents = 0
        expect(subject.maximum_capped?).to eq(false)
      end
    end
  end

  describe 'callbacks' do
    context 'upcase_code' do
      let(:subject) { build(:coupon) }
      it 'should upcase code' do
        subject.code = 'abc'
        subject.save
        expect(subject.code).to eq('ABC')
      end
    end

    context 'set_maximum_cap' do
      let(:subject) { build(:coupon, discount_by: 'price_discount', discount_price: 10, maximum_cap: 0 ) }
      it 'should set maximum_cap_cents to zero if maximum_cap_cents is nil' do
        subject.maximum_cap_cents = nil
        subject.save
        expect(subject.maximum_cap_cents).to eq(subject.discount_price_cents)
      end
    end
  end
end
