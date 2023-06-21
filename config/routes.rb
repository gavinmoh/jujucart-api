Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :admin do
        resources :workspaces
      end
    end
  end
  devise_for :admins, only: []
  devise_for :users,  only: []
  devise_for :customers, only: [] 
  
  namespace :api, :defaults => { format: :json } do
    namespace :v1 do
      namespace :revenue_monster do
        post :callback, to: 'application#callback'
      end

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
          put :void, on: :member
          get :versions, on: :member
          put :apply_coupon, on: :member
          put :remove_coupon, on: :member
          resources :line_items
        end
        resources :order_attachments
        resources :inventories
        resources :inventory_transactions do
          put :adjustment, on: :collection
        end
        resources :products do
          post :import, on: :collection
          get :import_template, on: :collection
        end
        resources :stores
        resources :categories
        resource  :settings, only: [:show, :update]
        resources :reports, only: [] do
          collection do
            get :overview
            get :best_seller_products
            get :best_seller_categories
          end
        end
        resources :coupons
        resources :wallets, only: [:index, :show] do
          resources :wallet_transactions, only: [:index, :show]
        end
        resources :promotion_bundles do
          resources :promotion_bundle_items
        end
        resources :sales_statements, only: [:index] do
          get :pdf, on: :member
        end
        resources :locations
        resources :inventory_transfers do
          member do
            put :transfer
            put :accept
            put :cancel
            put :revert
          end
        end
        resources :pos_terminals do
          member do
            post :initiate_payment
            put :cancel_payment
            put :card_payment_refund
          end
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
