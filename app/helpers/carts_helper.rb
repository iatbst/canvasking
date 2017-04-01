module CartsHelper
    
    include OrdersHelper
    
    # IMPORTANT: Anytime items changed in current cart, this function should be invoked
    # eg, items add,remove, edit quantity etc
    def update_total_price_and_quantity_in_cart
      
      # update price and quantity
      cart = get_current_cart
      price = 0
      quantity = 0
      cart.items.each do |item|
        price += item.price*item.quantity
        quantity += item.quantity
      end
      cart.price = price
      cart.quantity = quantity
      
      # update coupon price if necessary
      if cart.coupon_id
        cart.discount_price = calculate_discount_price(cart.price, cart.coupon)
      end
      
      cart.save!      
    end
    
    def update_total_price_in_cart
      cart = get_current_cart
      price = 0
      cart.items.each do |item|
        price += item.price*item.quantity
      end
      cart.price = price
      cart.save!
    end
    
    def update_total_quantity_in_cart
      cart = get_current_cart
      quantity = 0
      cart.items.each do |item|
        quantity += item.quantity
      end
      cart.quantity = quantity
      cart.save!     
    end
    
    def clear_cart
       cart = get_current_cart
       # specify this item belongs to the user
       cart.items.each do |item|
         item.user_id = current_user.id
         item.save
       end
       cart.items.clear
       cart.quantity = 0
       cart.price = 0
       cart.coupon_id = nil
       cart.discount_price = nil
       cart.save!
    end
    
    def empty_cart?
       cart = get_current_cart
       return cart.quantity == 0 && cart.price == 0
    end
      
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
        user_cart.price += session_cart.price
        user_cart.items.push(*session_cart.items)  # This step will update item cart_id from session cart to user cart
      end
    end

    def item_in_cart?(item)
      return get_current_cart.items.include?(item)    
    end
end
