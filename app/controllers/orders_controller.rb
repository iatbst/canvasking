class OrdersController < ApplicationController
  include CartsHelper
  before_action :authenticate_user!
  
  def new
    @cart = get_current_cart
    @shipping_cost = 0
    
    # TODO: Need to collect tax depend on state law
    @tax = 0
  end
  
  def index
    @orders = current_user.orders
  end
  
  def create
    @order = Order.create(order_params)
    
    # hook up order with current user
    @order.user_id = current_user.id
    
    # hook up order with all the items in the cart
    cart = get_current_cart
    @order.items.push(*cart.items)
    
    # Calculate all kind of prices
    @order.before_price = cart.price
    @order.shipping_price = 0
    # TODO: Need to collect tax depend on state law
    @order.tax_price = 0
    @order.total_price = @order.before_price + @order.shipping_price + @order.tax_price
    @order.save!
    
    # Empty Cart !
    cart.items.clear
    
    render 'show'
  end
  
  def show
    @order = Order.find(params[:id])
  end
  
  private
    def order_params
      params.require(:order).permit(:shipping_full_name, :shipping_address_1, :shipping_address_2, :shipping_city, :shipping_country, :shipping_state, :shipping_zip, :shipping_phone)
    end
end
