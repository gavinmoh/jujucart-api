class Api::V1::Storefront::StoreController < Api::V1::Storefront::ApplicationController
  
  def show
    render json: current_store, adapter: :json
  end

end
