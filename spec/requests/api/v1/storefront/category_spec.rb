require 'swagger_helper'

RSpec.describe 'api/v1/storefront/categories', type: :request do
  let(:store) { create(:store, store_type: 'online', hostname: 'www.example.com') }
  let(:id) { create(:category).id }

  path '/api/v1/storefront/categories' do
    get('list categories') do
      tags 'Storefront Categories'
      produces 'application/json'

      response(200, 'successful') do
        before do
          create_list(:category, 3, workspace: store.workspace)
        end

        run_test! do |response|
          response_body = JSON.parse(response.body)
          expect(response_body['categories'].count).to eq(3)
        end
      end
    end
  end
end
