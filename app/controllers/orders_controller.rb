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
    cart = get_current_cart
    # Warn: Stripe process money amount as cents
    charge_result = charge_money_by_stripe((cart.price*100).to_i)

    if charge_result[0] == false
      render 'new'   
    else
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

  end

  def show
    @order = Order.find(params[:id])
  end

  private

  def order_params
    params.require(:order).permit(:shipping_full_name, :shipping_address_1, :shipping_address_2, :shipping_city, :shipping_country, :shipping_state, :shipping_zip, :shipping_phone)
  end

  # Stripe way to charge the card
  def charge_money_by_stripe(amount)
    # Set your secret key: remember to change this to your live secret key in production
    # See your keys here: https://dashboard.stripe.com/account/apikeys
    Stripe.api_key = "sk_test_En5i3qV5z1Rm7JU0z1r3ppoR"

    # Get the credit card details submitted by the form
    token = params[:stripeToken]

    # Create a charge: this will charge the user's card
    begin
      charge = Stripe::Charge.create(
      :amount => amount, # Amount in cents
      :currency => "usd",
      :source => token,
      :description => "Example charge"
      )
    rescue Stripe::CardError => e
    # The card has been declined
      return false, e
    end
    return true, nil
  end
  
end
