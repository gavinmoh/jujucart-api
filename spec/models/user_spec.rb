require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:assigned_stores) }
    it { should have_many(:stores).through(:assigned_stores) }
    it { should have_many(:created_orders).dependent(:restrict_with_error) }

    it { should accept_nested_attributes_for(:assigned_stores).allow_destroy(true) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:role) }
    it { should define_enum_for(:role).with_values({ admin: 'admin', cashier: 'cashier' }).backed_by_column_of_type(:string) }

    context 'phone_number uniqueness validation' do
      it 'should validate phone_number uniqueness' do
        user1 = create(:user)
        user2 = build(:user, phone_number: user1.phone_number)
        expect(user2.valid?).to be_falsey
      end

      it 'should not validate phone_number uniqueness if phone_number is blank' do
        user = build(:user, phone_number: '')
        expect(user.valid?).to be_truthy
      end

      it 'should not validate phone_number uniqueness if phone_number is nil' do
        user = build(:user, phone_number: nil)
        expect(user.valid?).to be_truthy
      end
    end
  end

  describe 'scopes' do
    describe '.query' do
      let!(:query) { SecureRandom.alphanumeric(10) }
      let!(:user1) { create(:user, name: query) }
      let!(:user2) { create(:user, phone_number: query) }
      let!(:user3) { create(:user, email: "#{query}@test.com") }
      let!(:user4) { create(:user) }

      it 'should return users with name, phone_number or email like query' do
        users = User.query(query)
        expect(users).to match_array([user1, user2, user3])
        expect(users).not_to include(user4)
      end
    end
  end

  describe 'methods' do
    describe '#reset_password_link' do
      let!(:user) { create(:user) }
      let!(:token) { SecureRandom.alphanumeric(10) }

      it 'should return reset password link' do
        expect(user.reset_password_link(token)).to eq("#{Setting.web_host}/user/reset_password?token=#{token}")
      end
    end
  end

  describe 'class_methods' do
    describe '.find_for_database_authentication' do
      let!(:user) { create(:user) }

      it 'should find user by email or phone_number' do
        expect(User.find_for_database_authentication(email: user.email)).to eq(user)
        expect(User.find_for_database_authentication(email: user.phone_number)).to eq(user)
      end
    end
  end
end
