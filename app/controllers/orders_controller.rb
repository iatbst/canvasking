class OrdersController < ApplicationController
  include CartsHelper
  include ItemsHelper
  
  before_action :authenticate_user!
  def new
    @order = Order.new
    prepare_data_for_order_new_page
    update_coupon_in_cart
    
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
      
      # CHARGE MONEY: Stripe process money amount as cents
      if cart.coupon
        charge_amount = (cart.discount_price*100).to_i
      else
        charge_amount = (cart.price*100).to_i
      end
      @order.number = generate_unique_order_number
      charge_result = charge_money_by_stripe(charge_amount, @order)

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
        # TODO: Need to collect tax depend on state law and shipping cost
        @order.shipping_price = 0
        @order.tax_price = 0
        @order.before_price = cart.price
        if cart.coupon
          # If private coupon, mark as used
          if cart.coupon.public
            cart.coupon.used_count += 1
          else
            cart.coupon.used = true
          end
          cart.coupon.save
          @order.coupon_id = cart.coupon.id # Mark this order is using coupon
          @order.discount_price = cart.discount_price
          @order.total_price = @order.discount_price + @order.shipping_price + @order.tax_price
        else
          @order.total_price = @order.before_price + @order.shipping_price + @order.tax_price
        end
        @order.save!

        # Empty Cart !
        clear_cart
        
        # Send out order confirm email
        OrderMailer.order_confirm(current_user, @order).deliver_later
      
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
  end

  def add_to_cart
    item = Item.find(params[:id])
    new_item = item.dup
    
    new_item.quantity = 1
    new_item.order_id = nil
    
    if !item.image.file.nil? && \
        (item.image_tmp_paths.empty? || !item.image_tmp_paths['origin'].include?('https://'))
      new_item.image_tmp_paths = {}
      new_item.image_tmp_paths['origin'] = item.image.url
      new_item.image_tmp_paths['filter'] = item.image.filter.url
      new_item.image_tmp_paths['cart'] = item.image.cart.url
      new_item.image_tmp_paths['overview'] = item.image.overview.url
      new_item.image_tmp_paths['thumb'] = item.image.thumb.url
    end
    
    if !item.art_image.file.nil? && \
        (item.art_image_tmp_paths.empty? || 
          (item.art_image_tmp_paths['origin'] && !item.art_image_tmp_paths['origin'].include?('https://')))
      new_item.art_image_tmp_paths = {}
      new_item.art_image_tmp_paths['origin'] = item.art_image.url
      new_item.art_image_tmp_paths['filter'] = item.art_image.filter.url
      new_item.art_image_tmp_paths['cart'] = item.art_image.cart.url
      new_item.art_image_tmp_paths['overview'] = item.art_image.overview.url
      new_item.art_image_tmp_paths['thumb'] = item.art_image.thumb.url
    end 
  
    if new_item.save
      cart = get_current_cart
      cart.items.push(new_item)
      update_total_price_and_quantity_in_cart
    
      redirect_to cart_path
    else
      # Failed, stay in orders page
      redirect_to orders_path
    end
  end
  
  def apply_coupon
    code = params[:code].strip
    cart = get_current_cart
    
    if cart.coupon
      # Coupon already applied
      render json: {'error'=> "#{cart.coupon.code} is already applied, one coupon allowed per order. You need to remove it before applying another coupon."}
    elsif coupon_is_valid(code) && coupon_is_applicable(code, cart)
      # Valid Coupon code
      
      # update discount_price and coupon field in current cart
      coupon = Coupon.find_by_code(code)
      cart.coupon_id = coupon.id
      cart.discount_price = calculate_discount_price(cart.price, coupon)
      cart.save
      
      render json: {'discount_price'=> cart.discount_price, 'code'=>code, 'desc'=>coupon.description, 'saving'=> cart.price - cart.discount_price }
      
    else
      # Invalid Coupon code
      render json: {'error'=> @coupon_error}
    end
    
  end
  
  def remove_coupon
    cart = get_current_cart
    cart.discount_price = nil
    cart.coupon_id = nil
 
    if cart.save
      render json: {'price'=> cart.price }
    else
      render json: {'error'=> "Can't remove this coupon."}
    end
  end
  
  ############################## Private ############################## 
  private

  def coupon_is_valid(code)
    coupon = Coupon.find_by_code(code)
    if coupon.nil?
      @coupon_error = "Coupon not found."
      return false
    end
    
    if coupon.public
      if coupon.exp_date > Time.now
        return true
      else 
        @coupon_error = "Coupon #{code} is expired."
        return false
      end
    else
      if coupon.exp_date <= Time.now
        @coupon_error = "Coupon #{code} is expired."
        return false
      elsif current_user.id != coupon.user.id
        @coupon_error = "Coupon #{code} is invalid."
        return false
      elsif coupon.used
        @coupon_error = "Coupon #{code} is used before."
        return false       
      else
        return true
      end
    end  
  end
  
  # This function is different with `coupon_is_valid`, which verify if coupon valid.
  # This is used to inspect if coupon condition is met, eg, some coupon require spend at least amount to use
  def coupon_is_applicable(code, cart)
    coupon = Coupon.find_by_code(code)
    
    # Check if amount in cart exceed coupon least amount
    if coupon.condition_at_least_amount && cart.price < coupon.condition_at_least_amount.to_f
      @coupon_error = "Coupon #{code} is allowed on order which has amount $#{coupon.condition_at_least_amount} or higher."
      return false
    # TODO: other conditions may applied here
    else
      return true
    end
  end
  
  def calculate_discount_price(price, coupon)
    if coupon.discount_by_val
      return price - coupon.discount_val
    else
      return (price*((100 - coupon.discount_ptg).to_f/100.to_f)).round(2)
    end  
  end
  
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

  def update_coupon_in_cart
    # coupon need to update every time user checkout, in case, eg coupon expire, not meet coupon condition
    cart = get_current_cart
    coupon = cart.coupon
    if coupon && ( !coupon_is_valid(coupon.code) || !coupon_is_applicable(coupon.code, cart))
      cart.coupon = nil
      cart.discount_price = nil
      cart.save
    end
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
  def charge_money_by_stripe(amount, order)
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
      :description => "Order: #{order.number}"
      )
    rescue Stripe::CardError => e
    # The card has been declined
      return false, e.message
    end
    return true, nil
  end

end
