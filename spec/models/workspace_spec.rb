require 'rails_helper'

RSpec.describe Workspace, type: :model do
  describe 'associations' do
    it { should belong_to(:owner).optional.class_name('Account') }
    it { should belong_to(:created_by).optional.class_name('Account') }
    it { should have_many(:user_workspaces).dependent(:destroy) }
    it { should have_many(:users).through(:user_workspaces) }
    it { should have_many(:categories).dependent(:destroy) }
    it { should have_many(:coupons).dependent(:destroy) }
    it { should have_many(:customers).dependent(:destroy) }
    it { should have_many(:inventories).dependent(:destroy) }
    it { should have_many(:inventory_transfers).dependent(:destroy) }
    it { should have_many(:locations).dependent(:destroy) }
    it { should have_many(:orders).dependent(:destroy) }
    it { should have_many(:payments).dependent(:destroy) }
    it { should have_many(:pos_terminals).dependent(:destroy) }
    it { should have_many(:products).dependent(:destroy) }
    it { should have_many(:promotion_bundles).dependent(:destroy) }
    it { should have_many(:sales_statements).dependent(:destroy) }
    it { should have_many(:stores).dependent(:destroy) }
    it { should have_many(:wallets).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:workspace) }

    it { should validate_uniqueness_of(:subdomain) }
    it { should validate_exclusion_of(:subdomain).in_array(%w(www us ca jp app my)).with_message(/is reserved/) }
    it { should allow_value('https://example.com').for(:web_host) }
    it { should_not allow_value('foo').for(:web_host) }
    it { should validate_numericality_of(:coin_to_cash_rate).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(1) }
    it { should validate_numericality_of(:order_reward_amount).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:maximum_redeemed_coin_rate).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(1) }
  end

  describe 'callbacks' do
    describe 'before_validation' do
      describe '#set_owner_id' do
        it 'sets owner_id to created_by_id if owner_id is nil' do
          user = create(:user)
          workspace = build(:workspace, created_by: user)

          workspace.valid?
          expect(workspace.owner_id).to eq(user.id)
        end

        it 'does not set owner_id to created_by_id if owner_id is not nil' do
          owner = create(:user)
          user = create(:user)
          workspace = build(:workspace, owner: owner, created_by: user)

          workspace.valid?
          expect(workspace.owner_id).to eq(owner.id)
        end
      end

      describe '#set_default_settings' do
        it 'should set default settings' do
          workspace = create(:workspace)
          expect(workspace.coin_to_cash_rate).to eq(0.01)
          expect(workspace.order_reward_amount).to eq(0)
          expect(workspace.maximum_redeemed_coin_rate).to eq(0.5)
          expect(workspace.invoice_size).to eq('A4')
        end
      end
    end
  end
end
