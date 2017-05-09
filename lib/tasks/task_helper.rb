module TaskHelper
  def violate_taobao_shipping_limit(height, width)
    if height > width
      if (height*3 + width*2)*2.54 <= Canvasking::TAOBAO_SHIPPING_LIMIT
        return false
      else
        return true
      end
    else
      if (height*2 + width*3)*2.54 <= Canvasking::TAOBAO_SHIPPING_LIMIT
        return false
      else
        return true
      end      
    end
  end
  
  # Shipping thumb of rule ( may update accordingly )
  # h + w < 90cm => 83 ( <= 1kg )
  # 90cm < h + w < 110cm => 83 + 22 ( 1kg ~ 1.5kg )
  # 110cm < h + w < 130cm => 83 + 22*2 ( 1.5kg ~ 2.0kg )
  # 130cm < h + w < 150cm => 83 + 22*3 ( 2.0kg ~ 2.5kg )
  # h + w > 150cm => 83 + 22*4 ( > 2.5kg )
  def calculate_taobao_shipping_fee(h, w)
    base_price = 83
    add_price = 22
    if h + w < (90/2.54).to_f
      return base_price
    elsif h + w >= (90/2.54).to_f && h + w < (110/2.54).to_f
      return base_price + add_price
    elsif h + w >= (110/2.54).to_f && h + w < (130/2.54).to_f
      return base_price + add_price*2
    elsif h + w >= (130/2.54).to_f && h + w < (150/2.54).to_f
      return base_price + add_price*3
    else
      return base_price + add_price*4
    end
  end

  # Profit rate
  # Linear rate
  def calculate_profit_rate(h, w)
    rate = 0.01
    return 1.1 + (h + w - 24)*rate
  end
end