class SiteManageController < ApplicationController
  before_action :authenticate_user!
  
  def list_users
    @users = User.all
  end
end
