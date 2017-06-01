class PricingController < ApplicationController
  include PricingHelper
  
  def index    
    @size_price_obj = read_size_price_table
    @height_list = (12..32).step(2).to_a
    @width_list = (12..32).step(2).to_a
    @product_list = ['canvas']
    #Product.all.each {|p| @product_list.push(p.name)}
    @sizes = {'canvas'=>     
                  [  
                    "12\\\"x12\\\"", 
                    "12\\\"x16\\\"", 
                    "12\\\"x20\\\"", 
                    "12\\\"x24\\\"", 
                    "16\\\"x16\\\"",
                    "16\\\"x18\\\"", 
                    "16\\\"x20\\\"",
                    "16\\\"x24\\\"", 
                    "16\\\"x28\\\"", 
                    "20\\\"x20\\\"", 
                    "20\\\"x24\\\"", 
                    "20\\\"x28\\\"", 
                    "24\\\"x24\\\"", 
                    "24\\\"x26\\\"", 
                    
                    ],   
              'framed print'=>             \
                  [ "8\\\"x8\\\"",  \
                    "8\\\"x10\\\"", \
                    "10\\\"x10\\\"", \
                    "10\\\"x12\\\"", \
                    "12\\\"x12\\\"", \
                    "12\\\"x14\\\"", \
                    "14\\\"x14\\\"", \
                    "14\\\"x16\\\"", \
                    "16\\\"x16\\\"", \
                    "16\\\"x18\\\"", \
                    ]
              }
              
    
  end
  
  def query_price
    @size_price_obj = read_size_price_table
    product = params[:product]
    size = "#{params[:height]}\\\"x#{params[:width]}\\\""
    render json: {'price' => (@size_price_obj[product][size].to_f).round(2)}
  end
end
