require 'rails_helper'

RSpec.describe PromotionBundle, type: :model do
  describe 'associations' do
    it { should belong_to(:workspace) }
    it { should have_many(:promotion_bundle_items).dependent(:destroy) }
    it { should have_many(:line_items).dependent(:nullify) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:discount_by) }
    it { should validate_presence_of(:start_at) }
    it { should validate_presence_of(:end_at) }
    it { should validate_numericality_of(:discount_percentage).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:discount_percentage).is_less_than_or_equal_to(100) }

    context 'start_at and end_at' do
      let(:subject) { build(:promotion_bundle) }
      it 'should validate start_at_must_be_before_end_at' do
        subject.start_at = Time.zone.now + 1.day
        subject.end_at = Time.zone.now
        expect(subject).to_not be_valid
      end
    end

    context 'when discount_by is percentage_discount' do
      let(:subject) { build(:promotion_bundle, discount_by: 'percentage_discount') }
      it 'should validate discount_percentage' do
        subject.discount_percentage = 0
        expect(subject).to_not be_valid
      end
    end

    context 'when discount_by is price_discount' do
      let(:subject) { build(:promotion_bundle, discount_by: 'price_discount') }
      it 'should validate discount_price' do
        subject.discount_price = 0
        expect(subject).to_not be_valid
      end
    end
  end

  describe 'scope' do
    let!(:active_promotion_bundle) { create(:promotion_bundle, start_at: Time.zone.now - 1.day, end_at: Time.zone.now + 1.day) }
    let!(:scheduled_promotion_bundle) { create(:promotion_bundle, start_at: Time.zone.now + 1.day, end_at: Time.zone.now + 2.days) }
    let!(:expired_promotion_bundle) { create(:promotion_bundle, start_at: Time.zone.now - 2.days, end_at: Time.zone.now - 1.day) }

    it 'should return active promotion_bundles' do
      expect(PromotionBundle.active).to include(active_promotion_bundle)
      expect(PromotionBundle.active).to_not include(scheduled_promotion_bundle)
      expect(PromotionBundle.active).to_not include(expired_promotion_bundle)
    end

    it 'should return scheduled promotion_bundles' do
      expect(PromotionBundle.scheduled).to_not include(active_promotion_bundle)
      expect(PromotionBundle.scheduled).to include(scheduled_promotion_bundle)
      expect(PromotionBundle.scheduled).to_not include(expired_promotion_bundle)
    end

    it 'should return expired promotion_bundles' do
      expect(PromotionBundle.expired).to_not include(active_promotion_bundle)
      expect(PromotionBundle.expired).to_not include(scheduled_promotion_bundle)
      expect(PromotionBundle.expired).to include(expired_promotion_bundle)
    end
  end
end
