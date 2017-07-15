class CartsController < ApplicationController
  include CartsHelper
  include CouponsHelper
  
  # show current items in cart
  def cart
    # Calculate price
    # Warn: Need to update cart price every time items changed in cart for the safe side
    # update_total_price_and_quantity_in_cart
    @cart = get_current_cart
    
    # prepare coupons
    # @available_coupons = get_available_coupons(@cart)  
  end

  def apply_coupon
    coupon_id = params[:coupon_id]
    
    # remove coupon
    if coupon_id.nil? || coupon_id.empty?
      remove_coupon_in_cart
      render json: {'remove_coupon'=> true} and return
    end
    
    coupon = Coupon.find(coupon_id)
    cart = get_current_cart
    
    if coupon_is_valid?(coupon) && coupon_is_applicable?(coupon, cart)
      # Valid Coupon code
      
      # update discount_price and coupon field in current cart
      cart.coupon_id = coupon.id
      cart.discount_price = calculate_discount_price(cart.price, coupon)
      cart.save
      
      render json: {'discount_price'=> cart.discount_price, 
                    'code'=>coupon.code, 
                    'desc'=>coupon.description, 
                    'saving'=> cart.price - cart.discount_price,
                    'price'=>cart.price,
                    'item_count'=>cart.quantity }
      
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
      render json: {'price'=> cart.price,
                    'item_count'=>cart.quantity }
    else
      render json: {'error'=> "Can't remove this coupon."}
    end
  end
   
  
  private
  
  def get_available_coupons(cart)

    coupons = []
    # public coupons
    Coupon.where(public: true).each do |c|
      if coupon_is_valid?(c) && coupon_is_applicable?(c, cart)
        coupons.push(c)
      end
    end
    
    # private coupons, if user login
    if current_user
      current_user.coupons.where(:coupons => { :public => false }).each do |c|
        if coupon_is_valid?(c) && coupon_is_applicable?(c, cart)
          coupons.push(c)
        end
      end
    end
    
    return coupons
  end   
end
