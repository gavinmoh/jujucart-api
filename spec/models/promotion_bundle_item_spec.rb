require 'rails_helper'

RSpec.describe PromotionBundleItem, type: :model do
  describe 'associations' do
    it { should belong_to(:promotion_bundle) }
    it { should belong_to(:product) }
  end

  describe 'validations' do
    let(:subject) { create(:promotion_bundle_item) }
    it { should validate_uniqueness_of(:product_id).scoped_to(:promotion_bundle_id).case_insensitive }
    it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }
  end
end
