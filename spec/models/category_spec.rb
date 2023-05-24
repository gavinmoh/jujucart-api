require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'associations' do
    it { should have_many(:products) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
  end

  describe 'callbacks' do
    describe 'after_commit' do
      context 'update_slug' do
        it 'should update slug on create' do
          category = build(:category, name: 'Category Name')
          expect do
            category.save!
          end.to change(category, :slug).from(nil).to('category-name')
        end

        it 'should update slug on update' do
          category = create(:category, name: 'Category Name')
          expect do
            category.update(name: 'New Category Name')
          end.to change(category, :slug).from('category-name').to('new-category-name')
        end
      end
    end
  end

  describe 'scopes' do
    context 'query' do
      let(:query) { SecureRandom.alphanumeric(10) }
      let!(:category1) { create(:category, name: query) }
      let!(:category2) { create(:category) }

      it 'should return categories' do
        categories = Category.query(query)
        expect(categories).to include(category1)
        expect(categories).to_not include(category2)
      end
    end

    context 'with_sold_quantity_and_sales_amount_cents' do
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

      it 'should return categories with sold quantity and sales amount cents' do
        categories = Category.with_sold_quantity_and_sales_amount_cents
        expect(categories.first['sold_quantity']).to be_present
        expect(categories.first['sales_amount_cents']).to be_present
      end
    end
  end
end
