TheCarryProject::Application.routes.draw do
  resources :users
  resources :user_reviews
  resources :phones
  resources :sessions, only: [:new, :create, :destroy]
  resources :request_deliveries, only: [:create, :show, :edit, :update, :destroy] do
    put :accept, on: :member
    resources :comments
  end
  resources :suggest_deliveries, only: [:create, :show, :edit, :update, :destroy] do
    put :accept, on: :member
    resources :comments
  end
  resources :password_resets
  resources :conversations, only: [:index, :show, :new, :create] do
    member do
      post :reply
      post :trash
      post :untrash
    end
  end

  root to: 'static_pages#home'

  match '/signup', to: 'users#new'
  match '/signin', to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete

  #match '/how_it_works',    to: 'static_pages#how_it_works'
  #match '/dummy_paypal_redirection',    to: 'static_pages#dummy_paypal_redirection'
  match '/privacy_policy',    to: 'static_pages#privacy_policy'
  match '/terms_of_use',    to: 'static_pages#terms_of_use'

  match '/request', to:'request_deliveries#new'
  match '/requests', to:'request_deliveries#index'

  match '/pre_confirm_request/:accepted_request_id', to: 'request_deliveries#pre_confirm', as:'pre_confirm_request'
  match '/confirm_request', to:'request_deliveries#confirm'
  match '/pre_cancel_request/:accepted_request_id', to: 'request_deliveries#pre_cancel', as:'pre_cancel_request'
  match '/pre_complete_request/:accepted_request_id', to: 'request_deliveries#pre_complete', as:'pre_complete_request'
  match '/complete_request', to:'request_deliveries#complete'

  match '/pre_authorize_suggest/:accepted_suggest_id', to: 'suggest_deliveries#pre_authorize', as:'pre_authorize_suggest'
  match '/confirm_suggestion', to:'suggest_deliveries#confirm'
  match '/authorize_suggestion', to:'suggest_deliveries#authorize'
  match '/pre_cancel_suggest/:accepted_suggest_id', to: 'suggest_deliveries#pre_cancel', as:'pre_cancel_suggest'
  match '/pre_complete_suggest/:accepted_suggest_id', to: 'suggest_deliveries#pre_complete', as:'pre_complete_suggest'
  match '/complete_suggestion', to:'suggest_deliveries#complete'

  match '/suggest', to:'suggest_deliveries#new'
  match '/suggestions', to:'suggest_deliveries#index'

  match '/activity', to:'activities#index'

  match '/verify', to: 'users#verify'
  match '/confirm/:token', to: 'confirmations#confirm', as: 'confirm'

  match '/phone', to: 'phones#new'
  match '/send_code/:user_id', to: 'phones#send_code', as: 'send_code'
  match '/pre_verify_request/:accepted_request_id', to: 'phones#pre_verify_request', as: 'pre_verify_request'
  match '/pre_verify_suggest/:accepted_suggest_id', to: 'phones#pre_verify_suggest', as: 'pre_verify_suggest'
  match '/phone_verify/:user_id', to: 'phones#verify', as:'phone_verify'
  match '/phone_check', to: 'phone_verifications#phone_check'

  match '/reset_password', to: 'password_resets#new'
  match '/admin_reset/:user_id', to: 'password_resets#admin_reset', as:'admin_reset'

  match "empty_trash" => "users#empty_trash"

  match '/review', to: 'user_reviews#new'

  # Facebook authentication
  match '/auth/new' => 'authentications#new'
  match '/auth/:provider/callback' => 'authentications#create'
  match "/auth/failure" => "authentications#failure" #OMNIAUTH
  match "facebook/logout", :to => "authentications#logout", :as => :logout_authentication

  # PayPal routing
  get 'payments', to: 'payments#home', as: :home
  get 'payments/checkout', to: 'payments#checkout', as: :checkout
  get 'payments/cancel', to: 'payments#cancel', as: :cancel
  get 'payments/execute', to: 'payments#execute', as: :execute
  get 'payments/fail', to: 'payments#fail', as: :fail
  post 'payments/ipn_notification', to: 'payments#ipn_notification', as: :ipn_notification
  match '/details/:accepted_task_id/:req_or_sugg', to: 'payments#details', as: 'details'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
