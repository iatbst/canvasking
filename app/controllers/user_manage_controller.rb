class UserManageController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    # The default page of user is user edit page in devise
    redirect_to edit_user_registration_path
  end
  
  # show user coupons
  def coupons
    @coupons = current_user.coupons.where(:coupons => { :public => false }).sort_by {|c| c.created_at}.reverse
  end
  
  # show user orders
  def orders
    @open_orders = current_user.orders.where('status = ? OR status = ?', 'new', 'processing').sort_by { |obj| obj.created_at }.reverse
    @history_orders = current_user.orders.where(status: 'closed').sort_by { |obj| obj.created_at }.reverse    
  end
end
