namespace :price_maker do

  # This is a test function to fast make random product/size/price matrix and 
  # populate to /business/pricing.yml
  desc "Populate base price table"
  task :run do
    products = [
                'canvas',
                'framed print',
                #'split canvas', 
              ]
              
    # Considing long distance shipment, NO PRODUCT length > 1M
    table_size = 17

    pricing_obj = {}
    base_price = 0.0
    products.each do |product|
      pricing_obj[product] = {}
      h = 8
      w = 8
      base_price += 0
      bump_price = 0
      table_size.times.each do |x|
        table_size.times.each do |y|
          size = "#{h}\\\"x#{w}\\\""
          price = base_price + bump_price
          # bump_price += 1
          pricing_obj[product][size] = price
          w += 2
        end
        h += 2
        w = 8
      end
    end
    
    # write to yml
    File.open(Rails.root.join('business','pricing.yml'),"w") do |file|
      file.write pricing_obj.to_yaml
    end 
  end


  # populate price for CANVAS to /business/pricing.yml
  # According to price here: 
  #  https://item.taobao.com/item.htm?spm=a1z10.5-c.w4002-9476290978.51.xWbvhX&id=525855989381
  # - Cost = P1 + P2
  #  - P1: taobao price
  #  - P2: taobao shipping
  # - BASE_PRICE = Cost*Profit_rate
  # - FINAL_PRICE = BASE_PRICE/Marketing_rate
  desc "Populate price table for canvas"
  task :canvas_run do
    products = [
                'canvas',
                'framed print',
              ]
              
    # Considing long distance shipment, NO PRODUCT length > 1M
    table_size = 15
    
    # Dollar to RMB rate
    dollar_rate = Canvasking::DOLLAR_RATE
    # This is a average price: 2 ~ 2.5 kg; 83 + 22*3 = 149RMB; ~ 22 Dollar
    # Need to improve !
    shipment_fee = Canvasking::SHIPMENT_FEE
    # Current gross profit rate 50%
    base_prices = Canvasking::CANVAS_BASE_PRICES
    
    pricing_obj = {}
    products.each do |product|
      pricing_obj[product] = {}
      h = 12
      w = 12
      anchor = nil
      
      table_size.times.each do |x|
        table_size.times.each do |y|
          size = "#{h}\\\"x#{w}\\\""
          
          # Calculate Price
          if base_prices.has_key?("#{h}x#{w}")
            price = (base_prices["#{h}x#{w}"]/dollar_rate.to_f).round(2)
            anchor = h*w, price
          elsif base_prices.has_key?("#{w}x#{h}")
            price = (base_prices["#{w}x#{h}"]/dollar_rate.to_f).round(2)
            anchor = w*h, price
          else
            # Calculate price by anchor_price: 
            current_size = h*w
            price = (anchor[1].to_f * (current_size/anchor[0].to_f)).round(2)
          end
          
          # Add shipment fee
          # TODO: shipping fee should be scaled with weight
          price += shipment_fee
          
          # Base price
          price *= Canvasking::PROFIT_RATE
          
          # Final price
          price = price.to_f/Canvasking::MARKETING_RATE
          
          pricing_obj[product][size] = price.round(2)
          w += 2
        end
        h += 2
        w = 12
      end
    end
    
    # write to yml
    File.open(Rails.root.join('business','pricing.yml'),"w") do |file|
      file.write pricing_obj.to_yaml
    end 
  end
   
end