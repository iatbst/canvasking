module CartsHelper

    def get_current_cart
      begin
        cart = Cart.find(session[:cart_id])
      rescue ActiveRecord::RecordNotFound
        cart = Cart.create
        session[:cart_id] = cart.id
      end
      return cart
    end

end
