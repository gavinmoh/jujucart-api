require 'rails_helper'

RSpec.describe Store, type: :model do
  describe 'associations' do
    it { should belong_to(:workspace) }
    it { should have_one(:location).dependent(:destroy) }
    it { should have_many(:inventories).through(:location) }
    it { should have_many(:orders).dependent(:nullify) }
    it { should have_many(:products).through(:inventories) }
    it { should have_many(:assigned_stores).dependent(:destroy) }
    it { should have_many(:users).through(:assigned_stores) }
    it { should have_many(:pos_terminals).dependent(:nullify) }

    it { should accept_nested_attributes_for(:assigned_stores).allow_destroy(true) }
    it { should accept_nested_attributes_for(:pos_terminals).allow_destroy(true) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should allow_value('example.com').for(:hostname) }
    it { should_not allow_value('localhost').for(:hostname) }
    it { should_not allow_value('192.168.1.1').for(:hostname) }

    context 'hostname uniqueness' do
      subject { create(:store, :with_hostname) }
      it 'should be invalid with the same hostname' do
        store = build(:store, hostname: subject.hostname)
        expect(store.valid?).to be_falsey
      end

      it 'should allow blank hostname' do
        create(:store, hostname: nil)
        store = build(:store, hostname: nil)
        expect(store.valid?).to be_truthy
      end
    end

    it { should define_enum_for(:store_type).with_values(physical: 'physical', online: 'online').backed_by_column_of_type(:string) }
  end

  describe 'callbacks' do
    describe 'before_validation' do
      describe '#format_hostname' do
        it 'should format hostname' do
          store = build(:store, hostname: 'http://WWW.example.com/examplepage.html')
          store.valid?
          expect(store.hostname).to eq('www.example.com')
        end
      end
    end

    describe 'after_commit :create_location, on: :create' do
      it 'should create location' do
        workspace = create(:workspace)
        expect do
          create(:store, workspace: workspace)
        end.to change(Location, :count).by(1)
      end
    end
  end
end
