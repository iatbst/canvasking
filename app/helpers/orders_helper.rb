module OrdersHelper
  
  def calculate_discount_price(price, coupon)
    if coupon.discount_by_val
      return price - coupon.discount_val
    else
      return (price*((100 - coupon.discount_ptg).to_f/100.to_f)).round(2)
    end  
  end
  
end
