require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    subject { create(:order) }

    it { is_expected.to belong_to(:workspace) }
    it { is_expected.to belong_to(:customer).optional }
    it { is_expected.to belong_to(:store) }
    it { is_expected.to belong_to(:created_by).optional }
    it { is_expected.to have_one(:success_payment).dependent(:nullify).class_name('Payment').dependent(:nullify) }
    it { is_expected.to have_one(:pending_billplz_payment).dependent(:nullify).class_name('Payment').dependent(:nullify) }
    it { is_expected.to have_one(:pending_stripe_payment).dependent(:nullify).class_name('Payment').dependent(:nullify) }
    it { is_expected.to have_one(:order_coupon).dependent(:destroy) }
    it { is_expected.to have_one(:coupon).through(:order_coupon) }
    it { is_expected.to have_one(:valid_order_coupon).class_name('OrderCoupon') }
    it { is_expected.to have_many(:line_items).dependent(:destroy) }
    it { is_expected.to have_many(:products).through(:line_items) }
    it { is_expected.to have_many(:payments).dependent(:nullify) }
    it { is_expected.to have_many(:inventory_transactions).dependent(:nullify) }
    it { is_expected.to have_many(:order_attachments).dependent(:destroy) }

    it { is_expected.to accept_nested_attributes_for(:order_attachments).allow_destroy(true) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:order_type) }
    it { is_expected.to define_enum_for(:order_type).with_values(pos: 'pos', delivery: 'delivery', pickup: 'pickup', manual: 'manual').backed_by_column_of_type(:string) }
  end

  describe 'callbacks' do
    context 'before_validation' do
      describe '#calculate_delivery_fee' do
        it 'calls calculate_delivery_fee' do
          order = build(:order, status: 'pending', order_type: 'delivery')
          expect(order).to receive(:calculate_delivery_fee)
          order.valid?
        end

        it 'does not call calculate_delivery_fee if order is not pending' do
          order = build(:order, status: 'confirmed', order_type: 'delivery')
          expect(order).not_to receive(:calculate_delivery_fee)
          order.valid?
        end

        it 'does not call calculate_delivery_fee if order_type is not delivery' do
          order = build(:order, status: 'pending', order_type: 'pickup')
          expect(order).not_to receive(:calculate_delivery_fee)
          order.valid?
        end
      end

      describe '#set_redeemed_coin_value' do
        let!(:workspace) { create(:workspace, maximum_redeemed_coin_rate: 0.5, coin_to_cash_rate: 0.01) }
        let!(:customer) { create(:customer, workspace: workspace) }
        let!(:order) { create(:order, customer: customer, workspace: workspace) }
        let!(:product) { create(:product, price: 10, discount_price: 0, workspace: workspace) }
        let!(:line_item) { create(:line_item, order: order, product: product, quantity: 1) }

        it 'sets redeemed_coin_value' do
          create(:wallet_transaction, wallet: customer.wallet, amount: 1_000_000, transaction_type: 'topup')
          expect do
            order.update(redeemed_coin: 100)
          end.to(change { order.reload.redeemed_coin_value }
                    .from(Money.new(0))
                    .to(Money.from_amount(100 * workspace.coin_to_cash_rate)))
        end

        it 'does not set redeemed_coin_value if customer not present' do
          order.update(customer: nil)
          expect do
            order.update(redeemed_coin: order.subtotal_cents * workspace.maximum_redeemed_coin_rate)
          end.not_to(change { order.reload.redeemed_coin_value })
        end

        it 'does not set redeemed_coin_value if redeemed_coin is 0' do
          expect do
            order.update(redeemed_coin: 0)
          end.not_to(change { order.reload.redeemed_coin_value })
        end

        it 'does not set redeemed_coin_value if order is not pending' do
          order.update(status: 'confirmed')
          expect do
            order.update(redeemed_coin: 100)
          end.not_to(change { order.reload.slice(:redeemed_coin_value) })
        end

        it 'does not set redeemed_coin_value more than customer wallet amount' do
          create(:wallet_transaction, wallet: customer.wallet, amount: 10, transaction_type: 'topup')
          expect do
            order.update(redeemed_coin: 100)
          end.to(change { order.reload.redeemed_coin }.from(0).to(10)
             .and(change { order.reload.redeemed_coin_value }
                    .from(Money.new(0))
                    .to(Money.from_amount(10 * workspace.coin_to_cash_rate))))
        end

        it 'does not set redeemed_coin_value more than maximum_redeemed_coin_rate' do
          workspace.update(maximum_redeemed_coin_rate: 0.1)
          create(:wallet_transaction, wallet: customer.wallet, amount: 1_000_000, transaction_type: 'topup')
          expect do
            order.update(redeemed_coin: 500)
          end.to(change { order.reload.redeemed_coin }.from(0).to(100)
             .and(change { order.reload.redeemed_coin_value }
                    .from(Money.new(0))
                    .to(Money.from_amount(100 * workspace.coin_to_cash_rate))))
        end
      end

      describe '#set_total' do
        let!(:workspace) { create(:workspace, maximum_redeemed_coin_rate: 0.5, coin_to_cash_rate: 0.01) }
        let!(:customer) { create(:customer, workspace: workspace) }
        let!(:wallet_transaction) { create(:wallet_transaction, wallet: customer.wallet, amount: 1_000_000, transaction_type: 'topup') }
        let!(:order) { create(:order, status: 'pending', workspace: workspace) }
        let!(:product) { create(:product, price: 10, discount_price: 0, workspace: workspace) }
        let!(:line_item) { create(:line_item, order: order, quantity: 1, product: product) }

        it 'sets total' do
          expect do
            order.update(redeemed_coin_value: 100)
          end.to(change { order.reload.total_cents }.by(-order.reload.redeemed_coin_value_cents))
        end

        it 'does not set total if order is not pending' do
          order.update(status: 'confirmed')
          expect do
            order.update(redeemed_coin_value: 100)
          end.not_to(change { order.reload.total_cents })
        end
      end

      describe '#set_reward_amount' do
        let!(:workspace) { create(:workspace, order_reward_amount: 0) }
        let!(:customer) { create(:customer, workspace: workspace) }
        let!(:order) { create(:order, status: 'pending', customer: customer, workspace: workspace) }
        let!(:product) { create(:product, price: 10, discount_price: 0, workspace: workspace) }

        it 'sets reward_amount' do
          workspace.update(order_reward_amount: 10)
          expect do
            create(:line_item, order: order, quantity: 1, product: product)
          end.to(change { order.reload.reward_coin }.from(0).to(100))
        end

        it 'does not set reward_amount if order is not pending' do
          order.update(status: 'confirmed')
          expect do
            create(:line_item, order: order, quantity: 1, product: product)
          end.not_to(change { order.reload.reward_coin })
        end
      end
    end
  end

  describe 'scopes' do
    context 'query' do
      let!(:query) { SecureRandom.alphanumeric(10) }
      let!(:order1) { create(:order) }
      let!(:order2) { create(:order) }
      let!(:order3) { create(:order) }

      it 'returns orders with matching query' do
        order1.update_columns(nanoid: query)
        order2.customer.update_columns(name: query)
        orders = Order.query(query)
        expect(orders).to include(order1)
        expect(orders).to include(order2)
        expect(orders).not_to include(order3)
      end
    end

    context 'paid' do
      let!(:order1) { create(:order, status: 'confirmed') }
      let!(:order2) { create(:order, status: 'pending') }
      let!(:order3) { create(:order, status: 'pending_payment') }
      let!(:order4) { create(:order, status: 'failed') }

      it 'returns orders with status other than pending, pending_payment and failed' do
        orders = Order.paid
        expect(orders).to match_array([order1])
        expect(orders).not_to include(order2, order3, order4)
      end
    end

    describe '.include_pending_manual_order' do
      let!(:order1) { create(:order, status: 'pending', order_type: 'delivery') }
      let!(:order2) { create(:order, status: 'confirmed', order_type: 'delivery') }
      let!(:order3) { create(:order, status: 'completed', order_type: 'pickup') }
      let!(:order4) { create(:order, status: 'voided', order_type: 'pos') }
      let!(:order5) { create(:order, status: 'pending', order_type: 'manual') }
      let!(:order6) { create(:order, status: 'confirmed', order_type: 'manual') }
      let(:orders) { Order.include_pending_manual_order }

      it { expect(orders).not_to include(order1) }  # pending delivery order
      it { expect(orders).to include(order2, order3, order4, order5, order6) }
    end
  end

  describe 'methods' do
    describe '#recalculate_price' do
      let!(:order) { create(:order, status: 'pending') }
      let!(:product) { create(:product, price: 10, discount_price: 0) }
      let!(:line_item) { create(:line_item, order: order, quantity: 1, product: product) }
      let!(:coupon) { create(:coupon, discount_by: 'percentage_discount', discount_percentage: 10, minimum_spend: 15) }

      it 'recalculates price' do
        line_item.update_columns(quantity: 2, total_price_cents: 2000)
        expect do
          order.recalculate_price
        end.to(change { order.reload.subtotal_cents }.by(1000))
      end

      it 'recalculates price and discount' do
        create(:order_coupon, order: order, coupon: coupon)
        line_item.update_columns(quantity: 2, total_price_cents: 2000)
        expect do
          order.recalculate_price(false)
        end.not_to(change { order.reload.discount_cents })

        expect do
          order.recalculate_price # default is true
        end.to(change { order.reload.discount_cents }.by(200))
      end
    end

    describe '#display_delivery_address' do
      let!(:order) { build(:order) }

      it 'returns display address' do
        expect(order.display_delivery_address).to eq("#{order.delivery_address_unit_number}, #{order.delivery_address_street_address1}, #{order.delivery_address_street_address2}, #{order.delivery_address_postcode}, #{order.delivery_address_city}, #{order.delivery_address_state}")
        order.delivery_address_unit_number = ''
        expect(order.display_delivery_address).to eq("#{order.delivery_address_street_address1}, #{order.delivery_address_street_address2}, #{order.delivery_address_postcode}, #{order.delivery_address_city}, #{order.delivery_address_state}")
        order.delivery_address_street_address2 = ''
        expect(order.display_delivery_address).to eq("#{order.delivery_address_street_address1}, #{order.delivery_address_postcode}, #{order.delivery_address_city}, #{order.delivery_address_state}")
        order.delivery_address_postcode = ''
        expect(order.display_delivery_address).to eq("#{order.delivery_address_street_address1}, #{order.delivery_address_city}, #{order.delivery_address_state}")
        order.delivery_address_city = ''
        expect(order.display_delivery_address).to eq("#{order.delivery_address_street_address1}, #{order.delivery_address_state}")
        order.delivery_address_state = ''
        expect(order.display_delivery_address).to eq("#{order.delivery_address_street_address1}")
        order.delivery_address_street_address1 = ''
        expect(order.display_delivery_address).to eq('')
      end
    end

    describe '#coordinates_changed?' do
      let!(:order) { create(:order) }

      it 'returns true if coordinates changed' do
        order.assign_attributes(delivery_address_latitude: 1, delivery_address_longitude: 1)
        expect(order.send(:coordinates_changed?)).to be(true)
      end

      it 'returns false if coordinates not changed' do
        order.assign_attributes(delivery_address_unit_number: '123')
        expect(order.send(:coordinates_changed?)).to be(false)
      end
    end

    describe '#coordinates_complete?' do
      let!(:order) { create(:order) }

      it 'returns true if coordinates complete' do
        order.update(delivery_address_latitude: 1, delivery_address_longitude: 1)
        expect(order.send(:coordinates_complete?)).to be(true)
      end

      it 'returns false if coordinates not complete' do
        order.update(delivery_address_latitude: nil, delivery_address_longitude: 1)
        expect(order.send(:coordinates_complete?)).to be(false)
      end
    end
  end

  describe 'aasm' do
    context 'states' do
      it { is_expected.to have_state(:pending) }

      context 'normal order' do
        subject { create(:order, :with_line_items, order_type: 'pickup') }

        it { is_expected.to transition_from(:pending).to(:pending_payment).on_event(:checkout) }
      end

      context 'pos order' do
        subject { create(:order, :with_line_items, order_type: 'pos') }

        it { is_expected.to transition_from(:pending).to(:pending_payment).on_event(:pos_checkout) }
      end

      context 'manual order' do
        subject { create(:order, :with_line_items, order_type: 'manual') }

        it { is_expected.to transition_from(:pending).to(:confirmed).on_event(:confirm) }

        context 'confirmed order' do
          subject { create(:order, :with_line_items, order_type: 'manual', status: 'confirmed') }

          it { is_expected.to transition_from(:confirmed).to(:packed).on_event(:pack) }
          it { is_expected.to transition_from(:confirmed).to(:cancelled).on_event(:cancel) }
          it { is_expected.to transition_from(:confirmed).to(:completed).on_event(:complete) }
        end
      end

      context 'from pending_payment' do
        subject { create(:order, :with_line_items, status: 'pending_payment') }

        let!(:payment) { create(:payment, order: subject, status: 'success') }

        it { is_expected.to transition_from(:pending_payment).to(:confirmed).on_event(:confirm) }
        it { is_expected.to transition_from(:pending_payment).to(:failed).on_event(:fail) }
      end

      context 'from confirmed' do
        subject { create(:order, :with_line_items, status: 'confirmed') }

        it { is_expected.to transition_from(:confirmed).to(:packed).on_event(:pack) }
        it { is_expected.to transition_from(:confirmed).to(:cancelled).on_event(:cancel) }

        context 'pos order' do
          subject { create(:order, :with_line_items, status: 'confirmed', order_type: 'pos') }

          let!(:payment) { create(:payment, order: subject, status: 'success') }

          it { is_expected.to transition_from(:confirmed).to(:completed).on_event(:complete) }
        end
      end

      context 'from packed' do
        subject { create(:order, :with_line_items, status: 'packed') }

        it { is_expected.to transition_from(:packed).to(:shipped).on_event(:ship) }
        it { is_expected.to transition_from(:packed).to(:completed).on_event(:complete) }
      end

      context 'from shipped' do
        subject { create(:order, :with_line_items, status: 'shipped') }

        it { is_expected.to transition_from(:shipped).to(:completed).on_event(:complete) }
      end

      context 'from completed' do
        subject { create(:order, :with_line_items, status: 'completed', order_type: 'pos') }

        it { is_expected.to transition_from(:completed).to(:voided).on_event(:void) }
        it { is_expected.to transition_from(:completed).to(:refunded).on_event(:refund) }
      end
    end

    context 'guards' do
      describe '#enough_stock?' do
        let!(:store) { create(:store, validate_inventory: true) }
        let!(:order) { create(:order, store: store, order_type: 'pickup') }
        let!(:product) { create(:product) }
        let!(:line_item) { create(:line_item, order: order, product: product, quantity: 1) }

        it 'returns true if enough stock' do
          create(:inventory_transaction, quantity: 10, inventory: create(:inventory, product: product, location: store.location))
          expect(order.send(:enough_stock?)).to be(true)
        end

        it 'returns false if not enough stock' do
          expect(order.send(:enough_stock?)).to be(false)
        end

        it 'returns false if line item product deleted' do
          create(:inventory_transaction, quantity: 10, inventory: create(:inventory, product: product, location: store.location))
          line_item.product.destroy
          expect(order.send(:enough_stock?)).to be(false)
        end
      end

      describe '#has_line_items?' do
        it 'returns true if has line items' do
          order = create(:order, :with_line_items)
          expect(order.send(:has_line_items?)).to be(true)
        end

        it 'returns false if has no line items' do
          order = create(:order)
          expect(order.send(:has_line_items?)).to be(false)
        end
      end

      describe '#is_not_pos_order?' do
        it 'returns true if order_type is not pos' do
          order = create(:order, :with_line_items, order_type: 'delivery')
          expect(order.send(:is_not_pos_order?)).to be(true)
        end

        it 'returns false if order_type is pos' do
          order = create(:order, :with_line_items, order_type: 'pos')
          expect(order.send(:is_not_pos_order?)).to be(false)
        end
      end

      describe '#is_pos_order?' do
        it 'returns true if order_type is pos' do
          order = create(:order, :with_line_items, order_type: 'pos')
          expect(order.send(:is_pos_order?)).to be(true)
        end

        it 'returns false if order_type is not pos' do
          order = create(:order, :with_line_items, order_type: 'delivery')
          expect(order.send(:is_pos_order?)).to be(false)
        end
      end

      describe '#is_manual_order?' do
        it 'returns true if order_type is manual' do
          order = create(:order, :with_line_items, order_type: 'manual')
          expect(order.send(:is_manual_order?)).to be(true)
        end

        it 'returns false if order_type is not manual' do
          order = create(:order, :with_line_items, order_type: 'delivery')
          expect(order.send(:is_manual_order?)).to be(false)
        end
      end

      describe '#has_success_payment?' do
        it 'returns true if has success payment' do
          order = create(:order, :with_line_items, status: 'pending_payment')
          create(:payment, order: order, status: 'success')
          expect(order.send(:has_success_payment?)).to be(true)
        end

        it 'returns false if has no success payment' do
          order = create(:order, :with_line_items, status: 'pending_payment')
          expect(order.send(:has_success_payment?)).to be(false)
        end
      end
    end

    context 'after' do
      describe '#create_inventory_transactions' do
        let!(:order) { create(:order) }
        let!(:line_item) { create(:line_item, order: order) }

        it 'creates inventory transactions' do
          expect do
            order.send(:create_inventory_transactions)
          end.to(change { InventoryTransaction.count }.by(1))
        end
      end

      describe '#create_redeemed_coin_transaction' do
        let!(:workspace) { create(:workspace, maximum_redeemed_coin_rate: 0.5, coin_to_cash_rate: 0.01) }
        let!(:customer) { create(:customer, workspace: workspace) }
        let!(:wallet_transaction) { create(:wallet_transaction, wallet: customer.wallet, amount: 1_000_000, transaction_type: 'topup') }
        let!(:order) { create(:order, customer: customer, workspace: workspace) }
        let!(:product) { create(:product, price: 10, discount_price: 0, workspace: workspace) }
        let!(:line_item) { create(:line_item, order: order, product: product, quantity: 1) }

        it 'creates redeemed coin transaction' do
          order.update(redeemed_coin: 100)
          expect do
            order.send(:create_redeemed_coin_transaction)
          end.to(change { WalletTransaction.count }.by(1))
        end
      end

      describe '#create_return_inventory_transactions' do
        let!(:order) { create(:order) }
        let!(:line_item) { create(:line_item, order: order) }

        it 'creates return inventory transactions' do
          expect do
            order.send(:create_return_inventory_transactions)
          end.to(change { InventoryTransaction.count }.by(1))
        end
      end

      describe '#create_refund_coin_wallet_transaction' do
        let!(:workspace) { create(:workspace, maximum_redeemed_coin_rate: 0.5, coin_to_cash_rate: 0.01) }
        let!(:customer) { create(:customer, workspace: workspace) }
        let!(:wallet_transaction) { create(:wallet_transaction, wallet: customer.wallet, amount: 1_000_000, transaction_type: 'topup') }
        let!(:order) { create(:order, customer: customer, workspace: workspace) }
        let!(:product) { create(:product, price: 10, discount_price: 0, workspace: workspace) }
        let!(:line_item) { create(:line_item, order: order, product: product, quantity: 1) }

        it 'creates refund coin wallet transaction' do
          order.update(redeemed_coin: 100)
          expect do
            order.send(:create_refund_coin_wallet_transaction)
          end.to(change { WalletTransaction.count }.by(1))
        end
      end

      describe '#create_reward_transaction' do
        let!(:workspace) { create(:workspace, order_reward_amount: 10) }
        let!(:customer) { create(:customer, workspace: workspace) }
        let!(:order) { create(:order, customer: customer, workspace: workspace) }
        let!(:product) { create(:product, price: 10, discount_price: 0, workspace: workspace) }
        let(:line_item) { create(:line_item, order: order, product: product, quantity: 1) }

        before do
          line_item
        end

        it 'creates reward transaction' do
          expect do
            order.send(:create_reward_transaction)
          end.to(change { WalletTransaction.count }.by(1))
        end
      end

      describe '#destroy_order_reward' do
        let!(:workspace) { create(:workspace, order_reward_amount: 10) }
        let!(:customer) { create(:customer, workspace: workspace) }
        let!(:order) { create(:order, customer: customer, workspace: workspace) }
        let!(:product) { create(:product, price: 10, discount_price: 0, workspace: workspace) }
        let(:line_item) { create(:line_item, order: order, product: product, quantity: 1) }

        before do
          line_item
        end

        it 'destroys order reward' do
          order.send(:create_reward_transaction)
          expect do
            order.send(:destroy_order_reward)
          end.to(change { WalletTransaction.count }.by(-1))
        end
      end
    end
  end
end
