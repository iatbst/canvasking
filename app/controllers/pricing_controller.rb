class PricingController < ApplicationController
  include PricingHelper
  
  def index
    @size_price_obj = read_size_price_table
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
end
