Rails.application.routes.draw do
  get 'site_manage/list_users'
  get 'site_manage/show_prices'
  post 'site_manage/update_prices'
  get 'pricing/index'
  get 'pricing/query_price'

  devise_for :users, :controllers => { :sessions => "custom_sessions", :registrations => 'registrations' }
  get 'welcome/index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  get 'cart' => 'carts#cart'
  # get 'art_filter' => 'art_filter#filter'
  get '/items/art_filter/:id(.:format)' => 'items#art_filter', as: 'art_filter_item'
  # get '/orders/new(.:format)' => 'orders#new', as: 'new_order'
  get '/accounts/my_account' => 'accounts#my_account', as: 'manage_my_account'
  get '/orders/items/:id(.:format)' => 'orders#add_to_cart', as: 'add_to_cart'
  get '/upload_images_from_instagram' => 'items#empty_page'
  
  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  resources :items do
    resources :item_messages
  end
  resources :orders
  
  #mount Sidekiq::Web, at: '/sidekiq'
  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  

end
