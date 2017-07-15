class OrdersController < ApplicationController
  include CartsHelper
  include ItemsHelper
  
  before_action :authenticate_user!, except: [:new, :create, :apply_coupon, :remove_coupon]
  def new
    # Guest or User
    if current_user.nil? && params[:guest_check_out].nil?
      flash[:guest_check_out] = true
      flash[:notice] = "You need to login or continue as guest for checkout."
      redirect_to new_user_session_path
    end
    
    # If empty cart
    if empty_cart?
      redirect_to cart_path
    end
           
    @order = Order.new
    prepare_data_for_order_new_page
  end

  def index
    @open_orders = current_user.orders.where('status = ? OR status = ?', 'new', 'processing').sort_by { |obj| obj.created_at }.reverse
    @history_orders = current_user.orders.where(status: 'closed').sort_by { |obj| obj.created_at }.reverse
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
      
      # Re-calculate Price !!! This step is very important to charge 
      # correct amount
      update_total_price_and_quantity_in_cart
      
      # CHARGE MONEY: Stripe process money amount as cents
      cart = get_current_cart
      # NO COUPON !!!
      # if cart.coupon
        # charge_amount = (cart.discount_price*100).to_i
      # else
      charge_amount = (cart.price*100).to_i
      # end
      
      @order.number = generate_unique_order_number
      charge_result = charge_money_by_stripe(charge_amount, @order)

      # Charge failed, return back to order new page with error info
      if charge_result[0] == false
        @order.destroy
        flash['charge_error'] = charge_result[1]
        redirect_to new_order_path(:anchor => "charge_error")
      
      # =========== Both success, Order created !!! ===============
      else
        # hook up order with current user
        @order.user_id = current_user.id if current_user

        # hook up order with all the items in the cart
        cart = get_current_cart
        @order.items.push(*cart.items)

        # Calculate all kind of prices        
        # TODO: Need to collect tax depend on state law and shipping cost
        @order.shipping_price = 0
        @order.tax_price = 0
        @order.before_price = cart.price
        @order.total_price = @order.before_price + @order.shipping_price + @order.tax_price
        # end
        @order.save!

        # Empty Cart !
        clear_cart
            
        # Send out order confirm email
        OrderMailer.order_confirm(current_user, @order).deliver_later
        
        # Send out order notice email to Site admin
        OrderMailer.order_notify(current_user, @order).deliver_later
        
        @new_order_complete = true
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
    
    # User could only see their own orders
    if @order.user_id.nil? || current_user.nil? || @order.user_id != current_user.id
      redirect_to root_path
    end
  end

  
  ############################## Private ############################## 
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
    params.require(:order).permit(:shipping_full_name, :shipping_address_1, :shipping_address_2, :shipping_city, :country_id, :state_id, :shipping_zip, :shipping_phone, :guest_email)
  end
  
  
  def prepare_data_for_order_new_page
    @cart = get_current_cart
    @shipping_cost = prepare_shipping_cost
    @tax = prepare_tax
    
    # Prepare data for state/country select lists
    @countries = {}
    @country_select_list = []
    Country.all.each do |country|
      if Canvasking::SHIPPING_COUNTRIES.include?(country.name)
        # prepare for country select list
        @country_select_list.push([country.name, country.id])
        
        @countries[country.name] = []
        country.states.each do |state|
          @countries[country.name].push([state.name, state.id])
        end
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
  def charge_money_by_stripe(amount, order)
    # Set your secret key: remember to change this to your live secret key in production
    # See your keys here: https://dashboard.stripe.com/account/apikeys
    Stripe.api_key = ENV["stripe_secret_key"]

    # Get the credit card details submitted by the form
    token = params[:stripeToken]

    # Create a charge: this will charge the user's card
    begin
      charge = Stripe::Charge.create(
      :amount => amount, # Amount in cents
      :currency => "usd",
      :source => token,
      :description => "Order: #{order.number}"
      )
      
      # fill in payment info
      order.payment_info['last4'] = charge.source.last4
      order.payment_info['brand'] = charge.source.brand
      order.save!
      
    rescue Stripe::CardError => e
    # The card has been declined
      return false, e.message
    end
    return true, nil
  end

end
