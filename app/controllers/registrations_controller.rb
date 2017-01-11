class RegistrationsController < Devise::RegistrationsController
  before_filter :before_login, :only => :create
  after_filter :after_login, :only => :create
  include CartsHelper
  
  def before_login
  end

  def after_login
    merge_items_from_session_cart_to_user_cart
    update_total_price_in_cart
    update_total_quantity_in_cart
  end
  
  # Override Devise update action: change return page
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      bypass_sign_in resource, scope: resource_name
      respond_with resource, location: edit_user_registration_path # Only change
    else
      clean_up_passwords resource
      respond_with resource
    end
    
  end
  
  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
  end
end