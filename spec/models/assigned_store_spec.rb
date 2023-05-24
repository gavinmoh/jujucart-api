require 'rails_helper'

RSpec.describe AssignedStore, type: :model do
  describe 'associations' do
    it { should belong_to(:store) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    subject { create(:assigned_store) }
    it { should validate_uniqueness_of(:user).scoped_to(:store_id).case_insensitive }
  end
end
