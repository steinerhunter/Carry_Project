TheCarryProject::Application.routes.draw do
  default_url_options host: Rails.application.config.domain
  resources :users
  resources :user_reviews
  resources :phones
  resources :sessions, only: [:new, :create, :destroy]
  resources :request_deliveries, only: [:create, :show, :edit, :update, :destroy] do
    put :accept, on: :member
    put :take, on: :member
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
  match '/faq',    to: 'static_pages#faq'

  match '/request', to:'request_deliveries#new'
  match '/giveaways', to:'request_deliveries#index_takers'
  match '/pickups', to:'request_deliveries#index_transporters'

  match '/get_the_item/:request_delivery_id', to:'request_deliveries#get_the_item', as: 'get_the_item'
  match '/got_the_item/:request_delivery_id', to:'request_deliveries#got_the_item', as: 'got_the_item'
  match '/edit_request_cost/:request_delivery_id', to:'request_deliveries#edit_cost', as:'edit_request_cost'
  match '/edit_request_what/:request_delivery_id', to:'request_deliveries#edit_what', as:'edit_request_what'
  match '/edit_request_picture/:request_delivery_id', to:'request_deliveries#edit_picture', as:'edit_request_picture'
  match '/edit_request_from/:request_delivery_id', to:'request_deliveries#edit_from', as:'edit_request_from'
  match '/edit_request_delivery/:request_delivery_id', to:'request_deliveries#edit_delivery', as:'edit_request_delivery'
  match '/edit_request_to/:request_delivery_id', to:'request_deliveries#edit_to', as:'edit_request_to'
  match '/edit_request_size/:request_delivery_id', to:'request_deliveries#edit_size', as:'edit_request_size'
  match '/edit_request_due_date/:request_delivery_id', to:'request_deliveries#edit_due_date', as:'edit_request_due_date'
  match '/edit_sending_person/:request_delivery_id', to:'request_deliveries#edit_sending_person', as:'edit_sending_person'
  match '/edit_receiving_person/:request_delivery_id', to:'request_deliveries#edit_receiving_person', as:'edit_receiving_person'

  match '/pre_confirm_request/:accepted_request_id', to: 'request_deliveries#pre_confirm', as:'pre_confirm_request'
  match '/confirm_request', to:'request_deliveries#confirm'
  match '/pre_cancel_request/:accepted_request_id', to: 'request_deliveries#pre_cancel', as:'pre_cancel_request'
  match '/pre_complete_request/:accepted_request_id', to: 'request_deliveries#pre_complete', as:'pre_complete_request'
  match '/complete_request', to:'request_deliveries#complete'

  match '/suggest', to:'suggest_deliveries#new'
  match '/suggestions', to:'suggest_deliveries#index'

  match '/edit_suggest_cost/:suggest_delivery_id', to:'suggest_deliveries#edit_cost', as:'edit_suggest_cost'
  match '/edit_suggest_from/:suggest_delivery_id', to:'suggest_deliveries#edit_from', as:'edit_suggest_from'
  match '/edit_suggest_to/:suggest_delivery_id', to:'suggest_deliveries#edit_to', as:'edit_suggest_to'
  match '/edit_suggest_due_date/:suggest_delivery_id', to:'suggest_deliveries#edit_due_date', as:'edit_suggest_due_date'
  match '/edit_freq/:suggest_delivery_id', to:'suggest_deliveries#edit_freq', as:'edit_freq'

  match '/pre_authorize_suggest/:accepted_suggest_id', to: 'suggest_deliveries#pre_authorize', as:'pre_authorize_suggest'
  match '/confirm_suggestion', to:'suggest_deliveries#confirm'
  match '/authorize_suggestion', to:'suggest_deliveries#authorize'
  match '/pre_cancel_suggest/:accepted_suggest_id', to: 'suggest_deliveries#pre_cancel', as:'pre_cancel_suggest'
  match '/pre_complete_suggest/:accepted_suggest_id', to: 'suggest_deliveries#pre_complete', as:'pre_complete_suggest'
  match '/complete_suggestion', to:'suggest_deliveries#complete'

  match '/activity', to:'activities#index'

  match '/verify/:id', to: 'users#verify', as:'verify'
  match '/confirm/:token', to: 'confirmations#confirm', as: 'confirm'

  match '/phone', to: 'phones#new'
  match '/send_code/:user_id', to: 'phones#send_code', as: 'send_code'
  match '/pre_verify_request/:request_delivery_id/:coming_from', to: 'phones#pre_verify_request', as: 'pre_verify_request'
  match '/pre_verify_suggest/:suggest_delivery_id/:coming_from', to: 'phones#pre_verify_suggest', as: 'pre_verify_suggest'
  match '/phone_verify/:user_id', to: 'phones#verify', as:'phone_verify'
  match '/phone_check', to: 'phone_verifications#phone_check'

  match '/reset_password', to: 'password_resets#new'
  match '/admin_reset/:user_id', to: 'password_resets#admin_reset', as:'admin_reset'

  match "empty_trash" => "users#empty_trash"

  match '/review/:request_delivery_id', to: 'user_reviews#new', as:'review'

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
