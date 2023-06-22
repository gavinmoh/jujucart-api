require 'rails_helper'

RSpec.describe PosTerminal, type: :model do
  describe 'associations' do
    it { should belong_to(:workspace) }
    it { should belong_to(:store).optional }
  end

  describe 'callbacks' do
    context 'before_validation' do
      describe '#set_workspace_id' do
        let(:workspace) { create(:workspace) }
        let(:store) { create(:store, workspace: workspace) }
        let(:pos_terminal) { build(:pos_terminal, store: store, workspace: nil) }

        it 'sets workspace_id' do
          pos_terminal.valid?
          expect(pos_terminal.workspace_id).to eq(workspace.id)
        end
      end
    end
  end
end
