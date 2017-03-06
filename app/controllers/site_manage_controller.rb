class SiteManageController < ApplicationController
  before_action :authenticate_user!
  before_action :is_admin?
  include PricingHelper
  
  ################  Orders ######################
  
  ###################################
  #       3 status for order        #
  #  1. new 2. processing 3. closed #
  #                                 #
  #       5 status for taobao order #
  #  1. order placed                #
  #  2. product ship out to RC      #
  #  3. product reach RC            #
  #  4. product ship out from RC    #
  #  5. product reached             #
  ###################################
  def dashboard
    
  end
  
  def manage_orders
    @new_orders = Order.where(status: 'new').sort_by { |obj| obj.created_at }
    @processing_orders = Order.where(status: 'processing').sort_by { |obj| obj.created_at }
    @closed_orders = Order.where(status: 'closed').sort_by { |obj| obj.created_at }.reverse
    @active_tab = params['active_tab']
  end
  
  def new_order_detail
    @order = Order.find(params[:id])  
  end

  def processing_order_detail
    @order = Order.find(params[:id])  
  end
  
  def closed_order_detail
    @order = Order.find(params[:id])  
  end
  
  def update_order
    @order = Order.find(params[:id])
    
    if params['new_to_processing']
      
      # Process Invalid Input
      if !validate_oem_number(params)
        flash[:error] = params[:order].to_s
        flash[:notice] = "Order failed to mark from new to processing as invalid input"
        redirect_to new_order_detail_path(@order) and return      
      end
      
      @order.oem_info['oem_order_number'] = params[:order][:oem_order_number]
      @order.oem_info['oem_order_detail_url'] = generate_order_detail_url(params[:order][:oem_order_number])
      #@order.oem_info['oem_shipping_detail_url'] = generate_shipping_detail_url(params[:order][:oem_order_number])
      @order.notes = params[:order][:notes]
      @order.status = 'processing'
      @order.processing_status = 1 # order placed
      
      if @order.save
        # SUCCESS
        redirect_to site_manage_manage_orders_path and return 
      else
        # FAIL
        flash[:error] = @order.errors.to_s
        flash[:notice] = "Order failed to mark from new to processing as DB failure"
        redirect_to new_order_detail_path(@order) and return 
      end
    elsif params['processing_to_closed']
      @order.status = 'closed'
      @order.save
      @new_orders = Order.where(status: 'new').sort_by { |obj| obj.created_at }
      @processing_orders = Order.where(status: 'processing').sort_by { |obj| obj.created_at }
      @closed_orders = Order.where(status: 'closed').sort_by { |obj| obj.created_at }.reverse
      @active_tab = 'processing'
      
      render 'manage_orders'
    
    elsif params['closed_to_processing']
      @order.status = 'processing'
      @order.save
      @new_orders = Order.where(status: 'new').sort_by { |obj| obj.created_at }
      @processing_orders = Order.where(status: 'processing').sort_by { |obj| obj.created_at }
      @closed_orders = Order.where(status: 'closed').sort_by { |obj| obj.created_at }.reverse
      @active_tab = 'closed'
      
      render 'manage_orders'
    
    elsif params['update_notes']
      @order.notes = params[:order][:notes]   
      @order.save
      redirect_to(:back)
      
    elsif params['update_shipping_url']
      @order.oem_info['oem_shipping_detail_url'] = params[:order][:oem_shipping_detail_url]   
      @order.save
      redirect_to(:back)     
        
    elsif params['processing_status_update']
      @order.processing_status = params[:order][:processing_status]
      if @order.processing_status == 5
        @order.order_recv_date = Time.now
      end
      @order.save
      
      render json: { 'processing_status'=> @order.processing_status } and return
    end
  end
  
  # Update processing orders to closed order 30 days later after customer received the product
  def update_order_status
    @processing_orders = Order.where(status: 'processing', processing_status: 5)
    @processing_orders.each do | order|
      if (order.order_recv_date - Time.now) > Canvasking::ORDER_CLOSED_WAITING_TIME
        order.status = 'closed'
        order.save
      end
    end
    redirect_to "#{site_manage_manage_orders_path}?active_tab=processing"
  end
  
  
  
  ################  Users ######################
  
  def manage_users
    @users = User.all
  end
  
  ################  Users ######################
  
  def manage_prices
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
    
    redirect_to site_manage_manage_prices_path
  end
  
  ################  Coupons ######################
  def manage_coupons
    @public_coupons = Coupon.where(public: true).where('exp_date > ?', Time.now)
    @private_coupons = Coupon.where(public: false)
    @exp_coupons = Coupon.where(public: true).where('exp_date <= ?', Time.now)
    @active_tab = params['active_tab']
  end
  
  def new_coupon
    @coupon = Coupon.new
  end
  
  def edit_coupon
    @coupon = Coupon.find(params[:id])
    
  end
  
  def update_coupon
    @coupon = Coupon.find(params[:id])

    if params[:coupon][:public] == "true"
      # Public Coupon
      if @coupon.update(coupon_params)
        redirect_to site_manage_manage_coupons_path
      else
        render 'edit_coupon' # return with error
      end
    else
      # Private Coupon
      user = User.find(params[:coupon][:user_id])
      if user
        if @coupon.update(coupon_params)
          redirect_to site_manage_manage_coupons_path
        else
          render 'edit_coupon' # return with error
        end       
      else
        flash[:error] = 'user_id:' + params[:coupon][:user_id] + ' not found'
        render 'edit_coupon' # return with error
      end
    end
  end
  
  def create_coupon
    
    if params[:coupon][:public] == "true"
      # Public Coupon
      @coupon = Coupon.new(coupon_params)
      if @coupon.save
        redirect_to site_manage_manage_coupons_path
      else
        render 'new_coupon' # return with error
      end
    else
      # Private Coupon
      user = User.find_by_email(params[:coupon][:user_id])
      if user
        params[:coupon][:user_id] = user.id
        @coupon = Coupon.new(coupon_params)
        if @coupon.save
          redirect_to site_manage_manage_coupons_path
        else
          render 'new_coupon' # return with error
        end       
      else
        @coupon = Coupon.new
        flash[:error] = 'user:' + params[:coupon][:user_id] + ' not found'
        render 'new_coupon' # return with error
      end
    end
  end
  
  private
  def coupon_params
    return params.require('coupon').permit!  
  end
  
  # WARN: Only Website Administrator could access this controllers
  # 1 user.admin == true
  # 2 user.email in Canvasking::ADMINISTRATORS list
  # Both 1 and 2 condition should met
  def is_admin?
    unless Canvasking::ADMINISTRATORS.include?(current_user.email) && current_user.admin
      redirect_to root_path
    end
  end
  
  def validate_oem_number(params)
    order_number = params[:order][:oem_order_number]
    # TAOBAO order is composed of 16 numbers !
    return order_number.length == 16 && !/\A\d+\z/.match(order_number).nil?
  end
  
  def generate_order_detail_url(order_number)
    return "#{Canvasking::TAOBAO_ORDER_DETAIL_URL}?biz_order_id=#{order_number}"
  end

  # Deprecated : Not working ! TAOBAO_USER_ID always change
  def generate_shipping_detail_url(order_number)
    return "#{Canvasking::TAOBAO_SHIPPING_DETAIL_URL}?tId=#{order_number}&userId=#{Canvasking::TAOBAO_USER_ID}"
  end 
end
