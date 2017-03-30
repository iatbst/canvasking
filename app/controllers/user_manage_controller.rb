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
end
