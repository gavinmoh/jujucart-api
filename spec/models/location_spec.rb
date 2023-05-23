require 'rails_helper'

RSpec.describe Location, type: :model do
  describe 'associations' do
    it { should belong_to(:store).optional }
    it { should have_many(:inventories).dependent(:destroy) }
  end

  describe 'validations' do
    context 'when store is not present' do
      subject { build(:location, store: nil) }
      it { should validate_presence_of(:name) }
    end
  end
end
