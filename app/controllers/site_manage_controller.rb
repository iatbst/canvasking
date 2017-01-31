class SiteManageController < ApplicationController
  before_action :authenticate_user!
  
  def list_users
    @users = User.all
  end
  
  def show_prices
    @size_price_obj = read_size_price_table
    @height_list = (8..40).step(2).to_a
    @width_list = (8..40).step(2).to_a
  end
  
  def update_prices
    @size_price_obj = read_size_price_table
    @size_price_obj.each do |product, size_price_obj|
      if params[product]
        params[product].each do |size, price|
          @size_price_obj[product][size] = price.to_f
        end
      end
    end

    # write to yml
    File.open(Rails.root.join('business','pricing.yml'),"w") do |file|
      file.write @size_price_obj.to_yaml
    end 
    
    redirect_to site_manage_show_prices_path
  end
  
  private
      def read_size_price_table
        YAML.load(File.read(Rails.root.join('business','pricing.yml')))
      end
end
