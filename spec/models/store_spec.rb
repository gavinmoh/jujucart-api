require 'rails_helper'

RSpec.describe Store, type: :model do
  describe 'associations' do
    it { should have_one(:location).dependent(:destroy) }
    it { should have_many(:inventories).through(:location) }
    it { should have_many(:orders).dependent(:nullify) }
    it { should have_many(:products).through(:inventories) }
    it { should have_many(:assigned_stores).dependent(:destroy) }
    it { should have_many(:users).through(:assigned_stores) }
    it { should have_many(:pos_terminals).dependent(:destroy) }

    it { should accept_nested_attributes_for(:assigned_stores).allow_destroy(true) }
    it { should accept_nested_attributes_for(:pos_terminals).allow_destroy(true) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'callbacks' do
    describe 'after_commit :create_location, on: :create' do
      it 'should create location' do
        expect do
          create(:store)
        end.to change(Location, :count).by(1)
      end
    end
  end
end
