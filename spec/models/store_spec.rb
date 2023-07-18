require 'rails_helper'

RSpec.describe Store, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:workspace) }
    it { is_expected.to have_one(:location).dependent(:destroy) }
    it { is_expected.to have_many(:inventories).through(:location) }
    it { is_expected.to have_many(:orders).dependent(:nullify) }
    it { is_expected.to have_many(:products).through(:inventories) }
    it { is_expected.to have_many(:assigned_stores).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:assigned_stores) }
    it { is_expected.to have_many(:pos_terminals).dependent(:nullify) }

    it { is_expected.to accept_nested_attributes_for(:assigned_stores).allow_destroy(true) }
    it { is_expected.to accept_nested_attributes_for(:pos_terminals).allow_destroy(true) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to allow_value('example.com').for(:hostname) }
    it { is_expected.not_to allow_value('localhost').for(:hostname) }
    it { is_expected.not_to allow_value('192.168.1.1').for(:hostname) }
    it { is_expected.to allow_value('happystore').for(:subdomain) }
    it { is_expected.not_to allow_value('www').for(:subdomain) }
    it { is_expected.not_to allow_value('app').for(:subdomain) }

    describe 'hostname uniqueness' do
      let(:existing_store) { create(:store, :with_hostname) }

      it 'is invalid with the same hostname' do
        store = build(:store, hostname: existing_store.hostname)
        expect(store).to be_invalid
      end

      it 'allows blank hostname' do
        create(:store, hostname: nil)
        store = build(:store, hostname: nil)
        expect(store).to be_valid
      end
    end

    it { is_expected.to define_enum_for(:store_type).with_values(physical: 'physical', online: 'online').backed_by_column_of_type(:string) }
  end

  describe 'callbacks' do
    describe '#set_subdomain' do
      it 'sets subdomain' do
        store = build(:store, subdomain: nil, name: "Dave's Store")
        store.valid?
        expect(store.subdomain).to eq('davesstore')
      end
    end

    describe '#format_subdomain' do
      it 'formats subdomain' do
        store = build(:store, subdomain: "Dave's Store")
        store.valid?
        expect(store.subdomain).to eq('davesstore')
      end
    end

    describe '#format_hostname' do
      it 'formats hostname' do
        store = build(:store, hostname: 'http://WWW.example.com/examplepage.html')
        store.valid?
        expect(store.hostname).to eq('www.example.com')
      end
    end

    describe '#create_location' do
      it 'creates location' do
        workspace = create(:workspace)
        expect do
          create(:store, workspace: workspace)
        end.to change(Location, :count).by(1)
      end
    end
  end
end
