class CartsController < ApplicationController
  include CartsHelper
  
  # show current items in cart
  def cart
    # Calculate price
    # Warn: Need to update cart price every time items changed in cart for the safe side
    update_total_price_and_quantity_in_cart
    @cart = get_current_cart
    
  end

      
end
