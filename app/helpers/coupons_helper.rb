module CouponsHelper 
  
  def coupon_is_valid?(coupon)

    if coupon.nil?
      @coupon_error = "Coupon not found."
      return false
    end
    
    if coupon.public
      if coupon.exp_date > Time.now
        return true
      else 
        @coupon_error = "Coupon #{coupon.code} is expired."
        return false
      end
    else
      if current_user.nil?
        @coupon_error = "You need to login for user coupon."
        return false        
      elsif coupon.exp_date <= Time.now
        @coupon_error = "Coupon #{coupon.code} is expired."
        return false
      elsif current_user.id != coupon.user.id
        @coupon_error = "Coupon #{coupon.code} is invalid."
        return false
      elsif coupon.used
        @coupon_error = "Coupon #{coupon.code} is used before."
        return false       
      else
        return true
      end
    end  
  end
  
  # This function is different with `coupon_is_valid`, which verify if coupon valid.
  # This is used to inspect if coupon condition is met, eg, some coupon require spend at least amount to use
  def coupon_is_applicable?(coupon, cart)
    
    # Check if amount in cart exceed coupon least amount
    if coupon.condition_at_least_amount && cart.price < coupon.condition_at_least_amount.to_f
      @coupon_error = "Coupon #{coupon.code} is allowed on order which has amount $#{coupon.condition_at_least_amount} or higher."
      return false
    # TODO: other conditions may applied here
    else
      return true
    end
  end

  def coupon_code_is_valid?(code)
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
      if current_user.nil?
        @coupon_error = "You need to login for user coupon."
        return false        
      elsif coupon.exp_date <= Time.now
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
  def coupon_code_is_applicable?(code, cart)
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
  
  
  
  # Remove coupon in cart
  def remove_coupon_in_cart
    cart = get_current_cart
    if cart.coupon
      cart.coupon = nil
      cart.discount_price = nil
      cart.save
    end
  end
  
end