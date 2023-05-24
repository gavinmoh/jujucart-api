require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'associations' do
    it { should have_one(:wallet) }
    it { should have_many(:wallet_transactions).through(:wallet) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:phone_number) }
    it { should validate_uniqueness_of(:email).allow_blank.case_insensitive }

    context 'phone_number uniqueness validation' do
      it 'should validate phone_number uniqueness' do
        customer1 = create(:customer)
        customer2 = build(:customer, phone_number: customer1.phone_number)
        expect(customer2.valid?).to be_falsey
      end
    end
  end

  describe 'callbacks' do
    context 'after_commit' do
      context '#create_wallet' do
        let(:customer) { build(:customer) }

        it 'should create wallet' do
          expect do
            customer.save!
          end.to change(Wallet, :count).by(1)
        end
      end
    end

    context 'before_validation' do
      context '#strip_phone_number' do
        let(:customer) { build(:customer, phone_number: ' 601234567890 ') }

        it 'should strip phone_number' do
          customer.valid?
          expect(customer.phone_number).to eq('601234567890')
        end
      end

      context '#append_country_code_to_phone_number' do
        let(:customer) { build(:customer, phone_number: '01234567890') }

        it 'should append country code to phone_number' do
          customer.valid?
          expect(customer.phone_number).to eq('601234567890')
        end
      end

      context '#capitalize_name' do
        let(:customer) { build(:customer, name: 'john doe') }

        it 'should capitalize name' do
          customer.valid?
          expect(customer.name).to eq('John Doe')
        end
      end
    end    
  end

  describe 'scopes' do
    describe '#query' do
      let!(:query) { SecureRandom.alphanumeric(10) }
      let!(:customer1) { create(:customer) }
      let!(:customer2) { create(:customer, phone_number: query) }
      let!(:customer3) { create(:customer, email: "#{query}@test.com") }
      let!(:customer4) { create(:customer) }

      before do
        customer1.update_columns(name: query)
      end

      it 'should return customers with name, phone_number or email like query' do
        customers = Customer.query(query)
        expect(customers).to match_array([customer1, customer2, customer3])
        expect(customers).not_to include(customer4)
      end
    end
  end
end
