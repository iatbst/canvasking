class CartsController < ApplicationController
  include CartsHelper
  
  # show current items in cart
  def cart
    @cart = get_current_cart
    # Calculate price
    calculate_total_price_in_cart(@cart)
  end

  private
    def calculate_total_price_in_cart(cart)
      price = 0
      cart.items.each do |item|
        price += item.price*item.quantity
      end
      cart.price = price
      cart.save!
    end
      
end
