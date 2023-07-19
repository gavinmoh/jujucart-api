require 'rails_helper'

RSpec.describe Workspace, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:owner).optional.class_name('Account') }
    it { is_expected.to belong_to(:created_by).optional.class_name('Account') }
    it { is_expected.to have_many(:user_workspaces).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_workspaces) }
    it { is_expected.to have_many(:categories).dependent(:destroy) }
    it { is_expected.to have_many(:coupons).dependent(:destroy) }
    it { is_expected.to have_many(:customers).dependent(:destroy) }
    it { is_expected.to have_many(:inventories).dependent(:destroy) }
    it { is_expected.to have_many(:inventory_transfers).dependent(:destroy) }
    it { is_expected.to have_many(:locations).dependent(:destroy) }
    it { is_expected.to have_many(:orders).dependent(:destroy) }
    it { is_expected.to have_many(:payments).dependent(:destroy) }
    it { is_expected.to have_many(:pos_terminals).dependent(:destroy) }
    it { is_expected.to have_many(:products).dependent(:destroy) }
    it { is_expected.to have_many(:promotion_bundles).dependent(:destroy) }
    it { is_expected.to have_many(:sales_statements).dependent(:destroy) }
    it { is_expected.to have_many(:stores).dependent(:destroy) }
    it { is_expected.to have_many(:wallets).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:workspace) }

    it { is_expected.to validate_uniqueness_of(:subdomain) }
    it { is_expected.to validate_exclusion_of(:subdomain).in_array(%w[www us ca jp app my]).with_message(/is reserved/) }
    it { is_expected.to allow_value('https://example.com').for(:web_host) }
    it { is_expected.not_to allow_value('foo').for(:web_host) }
    it { is_expected.to validate_numericality_of(:coin_to_cash_rate).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(1) }
    it { is_expected.to validate_numericality_of(:order_reward_amount).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:maximum_redeemed_coin_rate).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(1) }

    describe 'default_payment_gateway' do
      subject { create(:workspace) }

      it { is_expected.to validate_presence_of(:default_payment_gateway) }
      it { is_expected.to validate_inclusion_of(:default_payment_gateway).in_array(%w[Stripe Billplz]) }
      it { is_expected.not_to allow_value('Paypal').for(:default_payment_gateway) }
    end
  end

  describe 'callbacks' do
    describe '#set_default_payment_gateway' do
      it 'set default_payment_gateway as Billplz if it is nil' do
        workspace = build(:workspace, default_payment_gateway: nil)

        workspace.valid?
        expect(workspace.default_payment_gateway).to eq('Billplz')
      end

      it 'does not set default_payment_gateway as Billplz if it is not nil' do
        workspace = build(:workspace, default_payment_gateway: 'Stripe')

        workspace.valid?
        expect(workspace.default_payment_gateway).to eq('Stripe')
      end
    end

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
      it 'sets default settings' do
        workspace = create(:workspace)
        expect(workspace.coin_to_cash_rate).to eq(0.01)
        expect(workspace.order_reward_amount).to eq(0)
        expect(workspace.maximum_redeemed_coin_rate).to eq(0.5)
        expect(workspace.invoice_size).to eq('A4')
      end
    end
  end
end
