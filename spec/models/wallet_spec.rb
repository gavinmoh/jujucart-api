require 'rails_helper'

RSpec.describe Wallet, type: :model do
  describe 'associations' do
    it { should belong_to(:customer).optional }
    it { should have_many(:wallet_transactions).dependent(:destroy) }
  end
end
