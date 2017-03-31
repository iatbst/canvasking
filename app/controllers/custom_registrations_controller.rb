class CustomRegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters
  include CartsHelper
  
  def create
    super
    # create new private coupon ( 40% off ) for the new user
    create_new_user_coupon(params[:user][:email])
    
    # merge items in cart if necessary
    merge_items_from_session_cart_to_user_cart
    update_total_price_and_quantity_in_cart 
    
    flash[:signup] = true
  end
  
  protected

  # Stay edit page after update
  def after_update_path_for(resource)
    edit_user_registration_path(resource)
  end  
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end  
  
  private
  
  def create_new_user_coupon(user_email)
    user_id = User.find_by_email(user_email).id
    # Use user email as coupon code
    coupon_code = user_email 
    coupon = Coupon.new
    coupon.user_id = user_id
    coupon.public = false
    coupon.code = coupon_code
    coupon.discount_ptg = 40
    coupon.exp_date = Time.now + 3600*24*90 # expire 90 days later
    coupon.description = "Exclusive 40% off for new user."
    coupon.discount_by_val = false
    
    coupon.save!
  end
end 