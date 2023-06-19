require 'rails_helper'

RSpec.describe PosTerminal, type: :model do
  describe 'associations' do
    it { should belong_to(:store) }
  end
end
