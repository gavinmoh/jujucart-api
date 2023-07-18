require 'sinatra/base'

class FakeBillplz < Sinatra::Base
  get '/api/v3/collections' do
    content_type :json
    status 200
    {
      collections: 3.times.map { fake_collection },
      page: params['page']
    }.to_json
  end

  post '/api/v3/collections' do
    content_type :json
    status 200
    fake_collection.to_json
  end

  get '/api/v3/collections/:id' do
    content_type :json
    status 200
    fake_collection.to_json
  end

  post '/api/v3/bills' do
    data = JSON.parse request.body.read
    content_type :json
    status 200
    fake_bill(data).to_json
  end

  get '/api/v3/bills/:id' do
    data = JSON.parse request.body.read
    content_type :json
    status 200
    fake_bill(data).to_json
  end

  private

    def fake_collection
      {
        id: SecureRandom.uuid,
        title: Faker::Lorem.word,
        logo: {
          thumb_url: nil,
          avatar_url: nil
        },
        split_payment: {
          email: nil,
          fixed_cut: nil,
          variable_cut: nil,
          split_header: false
        },
        status: "active"
      }
    end

    def fake_bill(data)
      {
        id: SecureRandom.uuid,
        collection_id: data['collection_id'],
        paid: false,
        state: "due",
        amount: data['amount'],
        paid_amount: 0,
        due_at: data['due_at'],
        email: data['email'],
        mobile: data['mobile'],
        name: data['name'],
        url: "https://www.billplz.com/bills/#{SecureRandom.uuid}",
        reference_1_label: data['reference_1_label'],
        reference_1: data['reference_1'],
        reference_2_label: data['reference_2_label'],
        reference_2: data['reference_2'],
        redirect_url: data['redirect_url'],
        callback_url: data['callback_url'],
        description: data['description']
      }
    end
end
