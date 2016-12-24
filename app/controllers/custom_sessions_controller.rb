class CustomSessionsController < Devise::SessionsController
  before_filter :before_login, :only => :create
  after_filter :after_login, :only => :create
  include CartsHelper

  def before_login
  end

  def after_login
    merge_items_from_session_cart_to_user_cart
  end
end