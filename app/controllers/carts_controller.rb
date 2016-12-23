class CartsController < ApplicationController
  include CartsHelper
  
  # show current items in cart
  def cart
    @cart = get_current_cart
    @items = @cart.items
  end

end
