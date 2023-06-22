require 'rails_helper'

RSpec.describe UserWorkspace, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:workspace) }
  end

  describe 'validations' do
    subject { create(:user_workspace) }

    it { should validate_uniqueness_of(:user).scoped_to(:workspace_id) }
  end
end
