require 'rails_helper'

RSpec.describe Inventory, type: :model do
  describe 'associations' do
    it { should belong_to(:workspace) }
    it { should belong_to(:location) }
    it { should belong_to(:product) }
    it { should have_many(:inventory_transactions).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:quantity).only_integer }
  end
end
