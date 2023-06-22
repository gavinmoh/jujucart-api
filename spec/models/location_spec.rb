require 'rails_helper'

RSpec.describe Location, type: :model do
  describe 'associations' do
    it { should belong_to(:workspace) }
    it { should belong_to(:store).optional }
    it { should have_many(:inventories).dependent(:destroy) }
  end

  describe 'validations' do
    context 'when store is not present' do
      subject { build(:location, store: nil) }
      it { should validate_presence_of(:name) }
    end
  end

  describe 'scopes' do
    context 'query' do
      let(:query) { SecureRandom.alphanumeric(10) }
      let!(:location) { create(:location, name: query) }
      let!(:store) { create(:store, name: query) }
      let!(:other_location) { create(:location) }

      it 'should return locations match name or store name' do
        locations = Location.query(query)
        expect(locations).to match_array([location, store.location])
        expect(locations).not_to include(other_location)
      end
    end

    context 'non_store' do
      let!(:location) { create(:location, store: nil) }
      let!(:store) { create(:store) }

      it 'should return locations without store' do
        locations = Location.non_store
        expect(locations).to match_array([location])
        expect(locations).not_to include(store.location)
      end
    end
  end
end
