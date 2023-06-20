require 'rails_helper'

RSpec.describe OrderAttachment, type: :model do
  describe 'associations' do
    it { should belong_to(:order) }
  end

  describe 'validations' do
    it { should validate_presence_of(:file) }
    it { should validate_presence_of(:name) }
  end

  describe 'scopes' do
    context '.query' do
      let!(:order_attachment) { create(:order_attachment, name: 'test') }

      it 'should return order attachment with name like test' do
        create_list(:order_attachment, 2)
        expect(OrderAttachment.query('test').count).to eq(1)
      end
    end
  end
end
