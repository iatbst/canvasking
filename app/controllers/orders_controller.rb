class OrdersController < ApplicationController
  include CartsHelper
  before_action :authenticate_user!
  def new
    @order = Order.new
    prepare_data_for_order_new_page

  end

  def index
    @orders = current_user.orders.sort_by { |obj| obj.created_at }.reverse
  end

  def create
    # First check if shipping form is valid
    # Second check if charging is valid
    # If any failed, return to order new page
    # If both success, return to order show page

    # Validate shipping address
    @order = Order.create(order_params)

    # Shipping form validation success, try to charge
    if @order.valid?
      cart = get_current_cart
      charge_amount = (cart.price*100).to_i # Reminder: Stripe process money amount as cents
      charge_result = charge_money_by_stripe(charge_amount)

      # Charge failed, return back to order new page
      if charge_result[0] == false
        @order.destroy
        @charge_error = charge_result[1]
        prepare_data_for_order_new_page
        render 'new'
      
      # Both success, Order created !!!
      else
        # hook up order with current user
        @order.user_id = current_user.id

        # hook up order with all the items in the cart
        cart = get_current_cart
        @order.items.push(*cart.items)

        # Calculate all kind of prices
        @order.before_price = cart.price
        # TODO: Need to collect tax depend on state law and shipping cost
        @order.shipping_price = 0
        @order.tax_price = 0
        @order.total_price = @order.before_price + @order.shipping_price + @order.tax_price
        @order.number = generate_unique_order_number
        @order.save!

        # Empty Cart !
        clear_cart
        
        # Send out order confirm email
        OrderMailer.order_confirm(current_user, @order).deliver_later
      
        render 'show'
      end

    # Shipping form validation failed, return back to order new page
    else
      prepare_data_for_order_new_page
      render 'new'
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  private

  def generate_unique_order_number
    # Find a unique one
    while true
      number = "A#{(0...8).map { rand(10).to_s }.join}"
      if Order.find_by_number(number).nil?
        return number
      end
    end
      
  end

  def order_params
    params.require(:order).permit(:shipping_full_name, :shipping_address_1, :shipping_address_2, :shipping_city, :country_id, :state_id, :shipping_zip, :shipping_phone)
  end

  def prepare_data_for_order_new_page
    @cart = get_current_cart
    @shipping_cost = prepare_shipping_cost
    @tax = prepare_tax
    
    # Prepare data for state/country select lists
    @countries = {}
    @country_select_list = []
    Country.all.each do |country|
      # prepare for country select list
      @country_select_list.push([country.name, country.id])
      
      @countries[country.name] = []
      country.states.each do |state|
        @countries[country.name].push([state.name, state.id])
      end
    end
  end
  
  # TODO
  def prepare_shipping_cost
    return 0
  end 
  
  # TODO
  def prepare_tax
    return 0
  end
  
  # Stripe way to charge the card
  def charge_money_by_stripe(amount)
    # Set your secret key: remember to change this to your live secret key in production
    # See your keys here: https://dashboard.stripe.com/account/apikeys
    Stripe.api_key = Canvasking::STRIPE_SECRET_KEY_TEST

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
      return false, e.message
    end
    return true, nil
  end

end
