class CustomSessionsController < Devise::SessionsController
  before_filter :before_login, :only => :create
  after_filter :after_login, :only => :create
  after_filter :after_logout, :only => :destroy
  include CartsHelper

  
  def before_login
  end

  def after_login
    merge_items_from_session_cart_to_user_cart
    update_total_price_and_quantity_in_cart 
    flash[:login] = true
  end
  
  def after_logout
    flash[:logout] = true
  end
end