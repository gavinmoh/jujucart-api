require 'rails_helper'

RSpec.describe NotificationToken, type: :model do
  describe 'associations' do
    it { should belong_to(:recipient).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:token) }
    it { should validate_uniqueness_of(:token) }
  end
end
