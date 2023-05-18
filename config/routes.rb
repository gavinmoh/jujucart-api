Rails.application.routes.draw do
  devise_for :admins, only: []
  devise_for :users,  only: []
  devise_for :customers, only: [] 
  
  namespace :api, :defaults => { format: :json } do
    namespace :v1 do
      namespace :user do
        devise_scope :user do
          post 'sign_in' => 'sessions#create'
          delete 'sign_out' => 'sessions#destroy'
          resource :passwords, only: [:create, :update]
        end
        
        resource :accounts, only: [:show, :update] do
          put :password, on: :collection
        end
        
        resources :users
        resources :customers, only: [:index, :show, :create, :update]
        resources :payments, only: [:index, :show]
        resources :orders do
          put :pack, on: :member
          put :ship, on: :member
          put :checkout, on: :member
          put :complete, on: :member
          get :versions, on: :member
          resources :line_items
        end
        resources :inventories
        resources :inventory_transactions
        resources :products
        resources :stores
        resources :categories
        resource  :settings, only: [:show, :update]
        resources :reports, only: [] do
          get :revenue,          on: :collection
          get :total_paid_order, on: :collection
          get :total_checkout,   on: :collection
          get :total_abandoned,  on: :collection
          get :total_order,      on: :collection
        end
      end
    end
  end

  # for previewing and testing pdf
  # namespace :api do
  #   namespace :v1 do
  #     namespace :web do
  #       resources :settlements, only: [:index] do
  #         get :pdf, on: :collection
  #       end
  #     end
  #   end
  # end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"  
end
