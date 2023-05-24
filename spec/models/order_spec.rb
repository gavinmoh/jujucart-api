require 'rails_helper'


RSpec.describe Order, type: :model do
  describe 'associations' do
    it { should belong_to(:customer).optional }
    it { should belong_to(:store) }
    it { should belong_to(:created_by).optional }
    it { should have_one(:success_payment) }
    it { should have_one(:order_coupon).dependent(:destroy) }
    it { should have_one(:coupon).through(:order_coupon) }
    it { should have_one(:valid_order_coupon).class_name('OrderCoupon') }
    it { should have_many(:line_items).dependent(:destroy) }
    it { should have_many(:products).through(:line_items) }
    it { should have_many(:payments).dependent(:nullify) }
    it { should have_many(:inventory_transactions).dependent(:nullify) }
  end

  describe 'validations' do
    it { should validate_presence_of(:order_type) }
    it { should define_enum_for(:order_type).with_values(pos: 'pos', delivery: 'delivery', pickup: 'pickup').backed_by_column_of_type(:string) }
  end

  describe 'callbacks' do
    context 'before_validation' do
      context '#calculate_delivery_fee' do
        it 'should call calculate_delivery_fee' do
          order = build(:order, status: 'pending', order_type: 'delivery')
          expect(order).to receive(:calculate_delivery_fee)
          order.valid?
        end

        it 'should not call calculate_delivery_fee if order is not pending' do
          order = build(:order, status: 'confirmed', order_type: 'delivery')
          expect(order).not_to receive(:calculate_delivery_fee)
          order.valid?
        end

        it 'should not call calculate_delivery_fee if order_type is not delivery' do
          order = build(:order, status: 'pending', order_type: 'pickup')
          expect(order).not_to receive(:calculate_delivery_fee)
          order.valid?
        end
      end

      context '#set_redeemed_coin_value' do
        let!(:customer) { create(:customer) }
        let!(:order) { create(:order, customer: customer) }
        let!(:product) { create(:product, price: 10, discount_price: 0) }
        let!(:line_item) { create(:line_item, order: order, product: product, quantity: 1) }
        
        before do
          Setting.maximum_redeemed_coin_rate = 0.5
          Setting.coin_to_cash_rate = 0.01
        end

        it 'should set redeemed_coin_value' do
          create(:wallet_transaction, wallet: customer.wallet, amount: 1_000_000, transaction_type: 'topup')
          expect do
            order.update(redeemed_coin: 100)
          end.to(change { order.reload.redeemed_coin_value }
                    .from(Money.new(0))
                    .to(Money.from_amount(100*Setting.coin_to_cash_rate)))
        end

        it 'should not set redeemed_coin_value if customer not present' do
          order.update(customer: nil)
          expect do
            order.update(redeemed_coin: order.subtotal_cents * Setting.maximum_redeemed_coin_rate)
          end.not_to(change { order.reload.redeemed_coin_value })
        end 

        it 'should not set redeemed_coin_value if redeemed_coin is 0' do
          expect do
            order.update(redeemed_coin: 0)
          end.not_to(change { order.reload.redeemed_coin_value })
        end

        it 'should not set redeemed_coin_value if order is not pending' do
          order.update(status: 'confirmed')
          expect do
            order.update(redeemed_coin: 100)
          end.not_to(change { order.reload.slice(:redeemed_coin_value) })
        end

        it 'should not set redeemed_coin_value more than customer wallet amount' do
          create(:wallet_transaction, wallet: customer.wallet, amount: 10, transaction_type: 'topup')
          expect do
            order.update(redeemed_coin: 100)
          end.to(change { order.reload.redeemed_coin }.from(0).to(10)
             .and(change { order.reload.redeemed_coin_value }
                    .from(Money.new(0))
                    .to(Money.from_amount(10*Setting.coin_to_cash_rate))))
        end

        it 'should not set redeemed_coin_value more than maximum_redeemed_coin_rate' do
          Setting.maximum_redeemed_coin_rate = 0.1
          create(:wallet_transaction, wallet: customer.wallet, amount: 1_000_000, transaction_type: 'topup')
          expect do
            order.update(redeemed_coin: 500)
          end.to(change { order.reload.redeemed_coin }.from(0).to(100)
             .and(change { order.reload.redeemed_coin_value }
                    .from(Money.new(0))
                    .to(Money.from_amount(100*Setting.coin_to_cash_rate))))
        end
      end

      context '#set_total' do
        let!(:customer) { create(:customer) }
        let!(:wallet_transaction) { create(:wallet_transaction, wallet: customer.wallet, amount: 1_000_000, transaction_type: 'topup') }
        let!(:order) { create(:order, status: 'pending') }
        let!(:product) { create(:product, price: 10, discount_price: 0) }
        let!(:line_item) { create(:line_item, order: order, quantity: 1, product: product) }

        before do
          Setting.maximum_redeemed_coin_rate = 0.5
          Setting.coin_to_cash_rate = 0.01
        end

        it 'should set total' do
          expect do
            order.update(redeemed_coin_value: 100)
          end.to(change { order.reload.total_cents }.by(-order.reload.redeemed_coin_value_cents))
        end

        it 'should not set total if order is not pending' do
          order.update(status: 'confirmed')
          expect do
            order.update(redeemed_coin_value: 100)
          end.not_to(change { order.reload.total_cents })
        end
      end

      context '#set_reward_amount' do
        let!(:customer) { create(:customer) }
        let!(:order) { create(:order, status: 'pending', customer: customer) }
        let!(:product) { create(:product, price: 10, discount_price: 0) }

        before do
          Setting.order_reward_amount = 10 # 10%
        end

        it 'should set reward_amount' do
          expect do
            create(:line_item, order: order, quantity: 1, product: product)
          end.to(change { order.reload.reward_coin }.from(0).to(100))
        end

        it 'should not set reward_amount if order is not pending' do
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

      it 'should return orders with matching query' do
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

      it 'should return orders with status other than pending, pending_payment and failed' do
        orders = Order.paid
        expect(orders).to match_array([order1])
        expect(orders).not_to include(order2, order3, order4)
      end
    end
  end

  describe 'methods' do
    context '#recalculate_price' do
      let!(:order) { create(:order, status: 'pending') }
      let!(:product) { create(:product, price: 10, discount_price: 0) }
      let!(:line_item) { create(:line_item, order: order, quantity: 1, product: product) }
      let!(:coupon) { create(:coupon, discount_by: 'percentage_discount', discount_percentage: 10, minimum_spend: 15) }

      it 'should recalculate price' do
        line_item.update_columns(quantity: 2, total_price_cents: 2000)
        expect do
          order.recalculate_price
        end.to(change { order.reload.subtotal_cents }.by(1000))
      end

      it 'should recalculate price and discount' do
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

    context '#display_address' do
      let!(:order) { build(:order) }

      it 'should return display address' do
        expect(order.display_address).to eq("#{order.unit_number}, #{order.street_address1}, #{order.street_address2}, #{order.postcode}, #{order.city}, #{order.state}")
        order.unit_number = ''
        expect(order.display_address).to eq("#{order.street_address1}, #{order.street_address2}, #{order.postcode}, #{order.city}, #{order.state}")
        order.street_address2 = ''
        expect(order.display_address).to eq("#{order.street_address1}, #{order.postcode}, #{order.city}, #{order.state}")
        order.postcode = ''
        expect(order.display_address).to eq("#{order.street_address1}, #{order.city}, #{order.state}")
        order.city = ''
        expect(order.display_address).to eq("#{order.street_address1}, #{order.state}")
        order.state = ''
        expect(order.display_address).to eq("#{order.street_address1}")
        order.street_address1 = ''
        expect(order.display_address).to eq('')
      end
    end

    context '#coordinates_changed?' do
      let!(:order) { create(:order) }

      it 'should return true if coordinates changed' do
        order.assign_attributes(latitude: 1, longitude: 1)
        expect(order.send(:coordinates_changed?)).to eq(true)
      end

      it 'should return false if coordinates not changed' do
        order.assign_attributes(unit_number: '123')
        expect(order.send(:coordinates_changed?)).to eq(false)
      end 
    end

    context '#coordinates_complete?' do
      let!(:order) { create(:order) }

      it 'should return true if coordinates complete' do
        order.update(latitude: 1, longitude: 1)
        expect(order.send(:coordinates_complete?)).to eq(true)
      end

      it 'should return false if coordinates not complete' do
        order.update(latitude: nil, longitude: 1)
        expect(order.send(:coordinates_complete?)).to eq(false)
      end
    end
  end

  describe 'aasm' do
    context 'states' do
      it { should have_state(:pending) }
      
      context 'normal order' do
        subject { create(:order, :with_line_items, order_type: 'pickup') }
        it { should transition_from(:pending).to(:pending_payment).on_event(:checkout) }
      end

      context 'pos order' do
        subject { create(:order, :with_line_items, order_type: 'pos') }
        it { should transition_from(:pending).to(:pending_payment).on_event(:pos_checkout) }
      end

      context 'from pending_payment' do
        subject { create(:order, :with_line_items, status: 'pending_payment') }
        let!(:payment) { create(:payment, order: subject, status: 'success') }
        it { should transition_from(:pending_payment).to(:confirmed).on_event(:confirm) }
        it { should transition_from(:pending_payment).to(:failed).on_event(:fail) }
      end

      context 'from confirmed' do
        subject { create(:order, :with_line_items, status: 'confirmed') }
        it { should transition_from(:confirmed).to(:packed).on_event(:pack) }
        it { should transition_from(:confirmed).to(:cancelled).on_event(:cancel) }

        context 'pos order' do
          subject { create(:order, :with_line_items, status: 'confirmed', order_type: 'pos') }
          let!(:payment) { create(:payment, order: subject, status: 'success') }
          it { should transition_from(:confirmed).to(:completed).on_event(:complete) }
        end
      end

      context 'from packed' do
        subject { create(:order, :with_line_items, status: 'packed') }
        it { should transition_from(:packed).to(:shipped).on_event(:ship) }
        it { should transition_from(:packed).to(:completed).on_event(:complete) }
      end

      context 'from shipped' do
        subject { create(:order, :with_line_items, status: 'shipped') }
        it { should transition_from(:shipped).to(:completed).on_event(:complete) }
      end

      context 'from completed' do
        subject { create(:order, :with_line_items, status: 'completed', order_type: 'pos') }
        it { should transition_from(:completed).to(:voided).on_event(:void) }
        it { should transition_from(:completed).to(:refunded).on_event(:refund) }
      end
    end

    context 'guards' do
      context '#customer_present?' do
        let!(:order) { create(:order, :with_line_items, order_type: 'delivery') }

        it 'should return true if customer is present' do
          expect(order.send(:customer_present?)).to eq(true)
        end

        it 'should return false if customer is not present' do
          order.update(customer: nil)
          expect(order.send(:customer_present?)).to eq(false)
        end
      end

      context '#enough_stock?' do
        let!(:store) { create(:store, validate_inventory: true) }
        let!(:order) { create(:order, store: store, order_type: 'pickup') }
        let!(:product) { create(:product) }
        let!(:line_item) { create(:line_item, order: order, product: product, quantity: 1) }

        it 'should return true if enough stock' do
          create(:inventory_transaction, quantity: 10, inventory: create(:inventory, product: product, location: store.location))
          expect(order.send(:enough_stock?)).to eq(true)
        end

        it 'should return false if not enough stock' do
          expect(order.send(:enough_stock?)).to eq(false)
        end

        it 'should return false if line item product deleted' do
          create(:inventory_transaction, quantity: 10, inventory: create(:inventory, product: product, location: store.location))
          line_item.product.destroy
          expect(order.send(:enough_stock?)).to eq(false)
        end
      end

      context '#has_line_items?' do
        it 'should return true if has line items' do
          order = create(:order, :with_line_items)
          expect(order.send(:has_line_items?)).to eq(true)
        end

        it 'should return false if has no line items' do
          order = create(:order)
          expect(order.send(:has_line_items?)).to eq(false)
        end
      end

      context '#is_not_pos_order?' do
        it 'should return true if order_type is not pos' do
          order = create(:order, :with_line_items, order_type: 'delivery')
          expect(order.send(:is_not_pos_order?)).to eq(true)
        end

        it 'should return false if order_type is pos' do
          order = create(:order, :with_line_items, order_type: 'pos')
          expect(order.send(:is_not_pos_order?)).to eq(false)
        end
      end

      context '#is_pos_order?' do
        it 'should return true if order_type is pos' do
          order = create(:order, :with_line_items, order_type: 'pos')
          expect(order.send(:is_pos_order?)).to eq(true)
        end

        it 'should return false if order_type is not pos' do
          order = create(:order, :with_line_items, order_type: 'delivery')
          expect(order.send(:is_pos_order?)).to eq(false)
        end
      end

      context '#has_success_payment?' do
        it 'should return true if has success payment' do
          order = create(:order, :with_line_items, status: 'pending_payment')
          create(:payment, order: order, status: 'success')
          expect(order.send(:has_success_payment?)).to eq(true)
        end

        it 'should return false if has no success payment' do
          order = create(:order, :with_line_items, status: 'pending_payment')
          expect(order.send(:has_success_payment?)).to eq(false)
        end
      end
    end

    context 'after' do
      context '#create_inventory_transactions' do
        let!(:order) { create(:order) }
        let!(:line_item) { create(:line_item, order: order) }

        it 'should create inventory transactions' do
          expect do
            order.send(:create_inventory_transactions)
          end.to(change { InventoryTransaction.count }.by(1))
        end
      end

      context '#create_redeemed_coin_transaction' do 
        let!(:customer) { create(:customer) }
        let!(:wallet_transaction) { create(:wallet_transaction, wallet: customer.wallet, amount: 1_000_000, transaction_type: 'topup') }
        let!(:order) { create(:order, customer: customer) }
        let!(:product) { create(:product, price: 10, discount_price: 0) }
        let!(:line_item) { create(:line_item, order: order, product: product, quantity: 1) }

        before do
          Setting.maximum_redeemed_coin_rate = 0.5
          Setting.coin_to_cash_rate = 0.01
        end

        it 'should create redeemed coin transaction' do
          order.update(redeemed_coin: 100)
          expect do
            order.send(:create_redeemed_coin_transaction)
          end.to(change { WalletTransaction.count }.by(1))
        end
      end

      context '#create_return_inventory_transactions' do
        let!(:order) { create(:order) }
        let!(:line_item) { create(:line_item, order: order) }

        it 'should create return inventory transactions' do
          expect do
            order.send(:create_return_inventory_transactions)
          end.to(change { InventoryTransaction.count }.by(1))
        end
      end

      context '#create_refund_coin_wallet_transaction' do
        let!(:customer) { create(:customer) }
        let!(:wallet_transaction) { create(:wallet_transaction, wallet: customer.wallet, amount: 1_000_000, transaction_type: 'topup') }
        let!(:order) { create(:order, customer: customer) }
        let!(:product) { create(:product, price: 10, discount_price: 0) }
        let!(:line_item) { create(:line_item, order: order, product: product, quantity: 1) }

        before do
          Setting.maximum_redeemed_coin_rate = 0.5
          Setting.coin_to_cash_rate = 0.01
        end

        it 'should create refund coin wallet transaction' do
          order.update(redeemed_coin: 100)
          expect do
            order.send(:create_refund_coin_wallet_transaction)
          end.to(change { WalletTransaction.count }.by(1))
        end
      end

      context '#create_reward_transaction' do
        let!(:customer) { create(:customer) }
        let!(:order) { create(:order, customer: customer) }
        let!(:product) { create(:product, price: 10, discount_price: 0) }
        let(:line_item) { create(:line_item, order: order, product: product, quantity: 1) }

        before do
          Setting.order_reward_amount = 10 # 10%
          line_item
        end

        it 'should create reward transaction' do
          expect do
            order.send(:create_reward_transaction)
          end.to(change { WalletTransaction.count }.by(1))
        end
      end

      context '#destroy_order_reward' do
        let!(:customer) { create(:customer) }
        let!(:order) { create(:order, customer: customer) }
        let!(:product) { create(:product, price: 10, discount_price: 0) }
        let(:line_item) { create(:line_item, order: order, product: product, quantity: 1) }

        before do
          Setting.order_reward_amount = 10 # 10%
          line_item
        end

        it 'should destroy order reward' do
          order.send(:create_reward_transaction)
          expect do
            order.send(:destroy_order_reward)
          end.to(change { WalletTransaction.count }.by(-1))
        end
      end      
    end
  end
end
