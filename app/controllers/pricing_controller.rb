class PricingController < ApplicationController
  include PricingHelper
  
  def index
    @size_price_obj = read_size_price_table
    @height_list = (8..40).step(2).to_a
    @width_list = (8..40).step(2).to_a
    @product_list = []
    Product.all.each {|p| @product_list.push(p.name)}
    @sizes = {'single canvas'=>     \
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
                    ],   
              'frame'=>             \
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
    render json: {'price' => @size_price_obj[product][size]}
  end
end
