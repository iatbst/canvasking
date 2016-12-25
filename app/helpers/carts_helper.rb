module CartsHelper

    def get_current_cart
      if user_signed_in?
        # If user signed in, get the user cart
        if current_user.cart.nil?
          current_user.cart = Cart.create
        end
        return current_user.cart
      else
        # If user not signed in, get the session cart
        begin
          cart = Cart.find(session[:cart_id])
        rescue ActiveRecord::RecordNotFound
          cart = Cart.create
          session[:cart_id] = cart.id
        end
        return cart
      end
    end
    
    def get_session_cart
        begin
          cart = Cart.find(session[:cart_id])
        rescue ActiveRecord::RecordNotFound
          cart = Cart.create
          session[:cart_id] = cart.id
        end
        return cart      
    end
    
    # Function only called after user signed in
    # Make sure this function only called after user login 
    def merge_items_from_session_cart_to_user_cart
      if user_signed_in?
        session_cart = get_session_cart
        user_cart = get_current_cart
        user_cart.items.push(*session_cart.items)  # This step will update item cart_id from session cart to user cart
      end
    end

end
