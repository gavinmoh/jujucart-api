require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:workspace) }
    it { is_expected.to belong_to(:order).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:payment_type) }
    it { is_expected.to define_enum_for(:payment_type).with_values({ cash: 'cash', terminal: 'terminal', online: 'online' }).backed_by_column_of_type(:string) }
    it { is_expected.to validate_inclusion_of(:service_provider).in_array(%w[Billplz Stripe RevenueMonster]).allow_blank }
    # context 'transaction_reference' do
    #   subject { build(:payment, payment_type: 'cash') }
    #   it { should validate_presence_of(:transaction_reference) }
    # end
  end

  describe 'scopes' do
    describe '.billplz' do
      let(:billplz_payment) { create(:payment, data: { service_provider: 'Billplz' }) }
      let(:stripe_payment) { create(:payment, data: { service_provider: 'Stripe' }) }
      let(:revenue_monster_payment) { create(:payment, data: { service_provider: 'RevenueMonster' }) }
      let(:billplz_payments) { described_class.billplz }

      it 'returns payments with service_provider as Billplz' do
        expect(billplz_payments).to include(billplz_payment)
        expect(billplz_payments).not_to include(stripe_payment)
        expect(billplz_payments).not_to include(revenue_monster_payment)
      end
    end

    describe '.stripe' do
      let(:billplz_payment) { create(:payment, data: { service_provider: 'Billplz' }) }
      let(:stripe_payment) { create(:payment, data: { service_provider: 'Stripe' }) }
      let(:revenue_monster_payment) { create(:payment, data: { service_provider: 'RevenueMonster' }) }
      let(:stripe_payments) { described_class.stripe }

      it 'returns payments with service_provider as Stripe' do
        expect(stripe_payments).to include(stripe_payment)
        expect(stripe_payments).not_to include(billplz_payment)
        expect(stripe_payments).not_to include(revenue_monster_payment)
      end
    end

    describe '.revenue_monster' do
      let(:billplz_payment) { create(:payment, data: { service_provider: 'Billplz' }) }
      let(:stripe_payment) { create(:payment, data: { service_provider: 'Stripe' }) }
      let(:revenue_monster_payment) { create(:payment, data: { service_provider: 'RevenueMonster' }) }
      let(:revenue_monster_payments) { described_class.revenue_monster }

      it 'returns payments with service_provider as RevenueMonster' do
        expect(revenue_monster_payments).to include(revenue_monster_payment)
        expect(revenue_monster_payments).not_to include(billplz_payment)
        expect(revenue_monster_payments).not_to include(stripe_payment)
      end
    end
  end

  describe 'callbacks' do
    describe '#set_workspace_id' do
      it 'sets workspace_id from order' do
        workspace = create(:workspace)
        order = create(:order, workspace: workspace)
        payment = build(:payment, order: order)
        payment.valid?
        expect(payment.workspace_id).to eq(workspace.id)
      end

      it 'does not set workspace_id if order is not present' do
        payment = build(:payment, order: nil, workspace: nil)
        payment.valid?
        expect(payment.workspace_id).to be_nil
      end
    end

    describe '#confirm_order' do
      it 'confirms order if payment is success' do
        order = create(:order, status: 'pending_payment', order_type: 'delivery')
        expect do
          create(:payment, order: order, status: 'success')
        end.to(change { order.reload.status }.from('pending_payment').to('confirmed'))
      end

      it 'does not confirm order if payment is not success' do
        order = create(:order, status: 'pending_payment')
        expect do
          create(:payment, order: order, status: 'failed')
        end.not_to(change { order.reload.status })
      end

      it 'confirms order if payment is mark as success' do
        order = create(:order, status: 'pending_payment', order_type: 'delivery')
        payment = create(:payment, order: order, status: 'pending')
        expect do
          payment.mark_as_success!
        end.to(change { order.reload.status }.from('pending_payment').to('confirmed'))
      end
    end

    describe '#refund_order' do
      it 'refunds order if payment is refunded' do
        order = create(:order, status: 'completed', order_type: 'pos')
        expect do
          create(:payment, order: order, status: 'refunded')
        end.to(change { order.reload.status }.from('completed').to('refunded'))
      end

      it 'does not refund order if payment is not refunded' do
        order = create(:order, status: 'completed', order_type: 'pos')
        expect do
          create(:payment, order: order, status: 'failed')
        end.not_to(change { order.reload.status })
      end

      it 'refunds order if payment is mark as refunded' do
        order = create(:order, status: 'completed', order_type: 'pos')
        payment = create(:payment, order: order, status: 'success')
        expect do
          payment.refund!
        end.to(change { order.reload.status }.from('completed').to('refunded'))
      end
    end
  end

  describe 'aasm' do
    describe 'states' do
      it { is_expected.to have_state(:pending) }
      it { is_expected.to transition_from(:pending).to(:success).on_event(:mark_as_success) }
      it { is_expected.to transition_from(:pending).to(:failed).on_event(:mark_as_failed) }
      it { is_expected.to transition_from(:pending).to(:cancelled).on_event(:mark_as_cancelled) }
      it { is_expected.to transition_from(:pending).to(:unknown).on_event(:mark_as_unknown) }
      it { is_expected.to transition_from(:success).to(:refunded).on_event(:refund) }

      context 'from unknown state' do
        subject { build(:payment, status: 'unknown', order: create(:order, status: 'pending_payment')) }

        it { is_expected.to transition_from(:unknown).to(:success).on_event(:mark_as_success) }
        it { is_expected.to transition_from(:unknown).to(:failed).on_event(:mark_as_failed) }
        it { is_expected.to transition_from(:unknown).to(:cancelled).on_event(:mark_as_cancelled) }
      end
    end
  end
end
