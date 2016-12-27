class CartsController < ApplicationController
  include CartsHelper
  
  # show current items in cart
  def cart
    @cart = get_current_cart
    # Calculate price
    # Warn: Need to update cart price every time items changed in cart
    update_total_price_in_cart(@cart)
  end

      
end
