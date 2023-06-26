require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:workspace) }
    it { is_expected.to have_many(:products) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:workspace_id) }
    it { is_expected.to validate_uniqueness_of(:slug).case_insensitive.scoped_to(:workspace_id).allow_blank }
  end

  describe 'callbacks' do
    describe '#update_slug' do
      it 'updates slug on create' do
        category = build(:category, name: 'Category Name')
        expect do
          category.save!
        end.to change(category, :slug).from(nil).to('category-name')
      end

      it 'updates slug on update' do
        category = create(:category, name: 'Category Name')
        expect do
          category.update(name: 'New Category Name')
        end.to change(category, :slug).from('category-name').to('new-category-name')
      end
    end
  end

  describe 'scopes' do
    describe '.query' do
      let(:query) { SecureRandom.alphanumeric(10) }
      let!(:category1) { create(:category, name: query) }
      let!(:category2) { create(:category) }
      let(:categories) { described_class.query(query) }

      it { expect(categories).to include(category1) }
      it { expect(categories).not_to include(category2) }
    end

    describe '.with_sold_quantity_and_sales_amount_cents' do
      let(:categories) { described_class.with_sold_quantity_and_sales_amount_cents }

      before do
        categories = create_list(:category, 3)
        products =
          3.times.map do
            create(:product, category: categories.sample)
          end
        orders = create_list(:order, 3)
        orders.each { create(:line_item, product: products.sample) }
        Order.update_all(completed_at: Time.current, status: :completed)
      end

      it { expect(categories.first['sold_quantity']).to be_present }
      it { expect(categories.first['sales_amount_cents']).to be_present }
    end
  end
end
