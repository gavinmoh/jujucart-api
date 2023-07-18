Rails.application.routes.draw do
  devise_for :admins, only: []
  devise_for :users,  only: []
  devise_for :customers, only: []

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      namespace :billplz do
        get  '/return/:jujucart_payment_id',   to: 'application#return',   as: :return
        post '/callback/:jujucart_payment_id', to: 'application#callback', as: :callback
      end

      namespace :revenue_monster do
        post :callback, to: 'application#callback'
      end

      namespace :admin do
        resources :workspaces
      end

      namespace :user do
        devise_scope :user do
          post   'sign_in'  => 'sessions#create'
          delete 'sign_out' => 'sessions#destroy'
          post   'sign_up'  => 'registrations#create'
          resource :passwords, only: [:create, :update]
        end

        resource :accounts, only: [:show, :update] do
          put :password, on: :collection
        end

        resources :users
        resources :customers, only: [:index, :show, :create, :update]
        resources :payments, only: [:index, :show]
        resources :orders do
          resources :line_items
          collection do
            put :bulk_confirm
            put :bulk_pack
            put :bulk_complete
            put :bulk_void
          end
          member do
            put :pack
            put :ship
            put :checkout
            put :confirm
            put :complete
            put :void
            get :versions
            put :apply_coupon
            put :remove_coupon
          end
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
        resource :workspace, only: [:show, :update], controller: :workspace
      end

      namespace :storefront do
        resource :store, only: [:show], controller: :store
        resources :products, only: [:index, :show] do
          get :all, on: :collection
        end
        resources :categories, only: [:index]
        resources :orders do
          resources :line_items
          member do
            put :checkout
            put :complete
            put :apply_coupon
            put :remove_coupon
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
