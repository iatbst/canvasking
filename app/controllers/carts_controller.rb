class CartsController < ApplicationController
  include CartsHelper
  
  # show current items in cart
  def cart
    # Calculate price
    # Warn: Need to update cart price every time items changed in cart
    update_total_price_in_cart
    update_total_quantity_in_cart
    @cart = get_current_cart
    
  end

      
end
