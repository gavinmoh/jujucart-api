require 'swagger_helper'

RSpec.describe 'api/v1/user/stores', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:workspace) { user.current_workspace }

  before do
    StripeMock.start
  end

  after do
    StripeMock.stop
  end

  path '/api/v1/user/stripe/connect' do
    post('connect stripe') do
      tags 'User Stripe'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :refresh, in: :query, type: :boolean, required: false, description: 'Refresh expired link'

      response(200, 'successful') do
        run_test!
      end

      response(400, 'already connected') do
        before do
          workspace.update(stripe_account_id: '123')
        end

        run_test!
      end
    end
  end
end
