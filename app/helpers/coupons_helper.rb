module CouponsHelper 
  
  def coupon_is_valid(code)
    coupon = Coupon.find_by_code(code)
    if coupon.nil?
      return false
    end
    
    if coupon.public
      if coupon.exp_date > Time.now
        return true
      else 
        return false
      end
    else
      if coupon.exp_date <= Time.now
        return false
      elsif current_user.id != coupon.user.id
        return false
      elsif coupon.used
        return false       
      else
        return true
      end
    end  
  end
  
end