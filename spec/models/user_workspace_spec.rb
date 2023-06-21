require 'rails_helper'

RSpec.describe UserWorkspace, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:workspace) }
  end
end
