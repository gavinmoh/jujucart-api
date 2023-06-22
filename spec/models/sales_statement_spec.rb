require 'rails_helper'

RSpec.describe SalesStatement, type: :model do
  describe 'associations' do
    it { should belong_to(:workspace) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:from_date) }
    it { should validate_presence_of(:to_date) }
  end

  describe 'callbacks' do
    context 'before_create' do
      context '#set_statement_number' do
        it 'sets the statement_number' do
          sales_statement = build(:sales_statement)
          sales_statement.save
          expect(sales_statement.statement_number).to be_present
        end
      end

      context '#set_charges' do
        let(:workspace) { create(:workspace) }

        it 'sets the charges' do
          coupon = create(:coupon, discount_by: 'percentage_discount', discount_percentage: 10, workspace: workspace)
          3.times do
            order = create(:order, :with_line_items, order_type: 'pos', workspace: workspace)
            create(:order_coupon, order: order, coupon: coupon)
            order.pos_checkout!
            create(:payment, status: 'success', order: order, created_at: Faker::Time.between(from: Time.current.last_month.beginning_of_month, to: Time.current.last_month.end_of_month))
            order.complete!
          end
          sales_statement = build(:sales_statement, workspace: workspace)
          sales_statement.save
          expect(sales_statement.total_sales_cents).to be > 0
          # expect(sales_statement.total_delivery_fee_cents).to > 0
          expect(sales_statement.total_discount_cents).to be > 0
          # expect(sales_statement.total_redeemed_coin_cents).to be > 0
          expect(sales_statement.total_gross_profit_cents).to be > 0
        end
      end
    end
  end
end

