require 'swagger_helper'

RSpec.describe 'api/v1/storefront/stores', type: :request do
  let(:store) { create(:store, store_type: 'online') }

  path '/api/v1/storefront/store' do
    get('show stores') do
      tags 'Storefront Stores'
      produces 'application/json'

      parameter name: 'X-STORE-ID', in: :header, type: :string, required: false, description: 'Store ID'

      response(200, 'successful') do
        context 'when setting X-STORE-ID header' do
          let(:'X-STORE-ID') { store.id }

          run_test!
        end

        context 'when using hostname' do
          let!(:store) { create(:store, store_type: 'online') }
          let(:mock_request) { instance_double(ActionDispatch::Request) }

          before do
            allow(mock_request).to receive(:referer).and_return("https://#{store.hostname}/")
          end

          run_test!
        end
      end

      response(400, 'bad request') do
        run_test!
      end
    end
  end
end
