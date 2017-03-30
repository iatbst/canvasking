Rails.application.routes.draw do
  get 'site_manage/manage_users'
  get 'site_manage/manage_prices'
  get 'site_manage/manage_orders'
  get 'site_manage/manage_coupons'
  get 'site_manage/new_coupon'
  get 'site_mange/edit_coupon/:id(.:format)' => 'site_manage#edit_coupon', as: 'site_manage_edit_coupon'
  get 'site_manage/update_order_status'
  get 'site_manage/new_order_detail/:id(.:format)' => 'site_manage#new_order_detail', as: 'new_order_detail'
  get 'site_manage/processing_order_detail/:id(.:format)' => 'site_manage#processing_order_detail', as: 'processing_order_detail'
  get 'site_manage/closed_order_detail/:id(.:format)' => 'site_manage#closed_order_detail', as: 'closed_order_detail'
  post 'site_manage/update_order/:id(.:format)' => 'site_manage#update_order', as: 'update_order'
  get 'site_manage/dashboard'
  post 'site_manage/update_prices'
  post 'site_manage/create_coupon'
  patch 'site_manage/update_coupon/:id(.:format)'=> 'site_manage#update_coupon', as: 'site_manage_update_coupon'
  get 'pricing/index'
  get 'pricing/query_price'

  devise_for :users, :controllers => { :sessions => "custom_sessions", :registrations => "custom_registrations"}
  
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
  post '/orders/apply_coupon'
  get '/orders/remove_coupon'
  post '/welcome/image_upload'
  
  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  resources :items do
    resources :item_messages
  end
  resources :orders
  # resources :coupons

  # Any resources need ADMIN authentications
  # - Sidekiq UI
  # - exception_logger UI
  #
  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.admin? && Canvasking::ADMINISTRATORS.include?(u.email)} do
    mount Sidekiq::Web => '/sidekiq'
    mount ExceptionLogger::Engine => "/exception_logger"
  end

  # Controller: about
  get 'about/privacy_policy'
  get 'about/terms_of_use'
  
  # Error Pages
  get '/404', :to => 'application#page_not_found'
  get '/500', :to => 'application#internal_server_error'
  get '/503', :to => 'application#service_unavailable'
  
  # user_manage
  get 'user_manage/index'
  get 'user_manage/coupons'
  
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
