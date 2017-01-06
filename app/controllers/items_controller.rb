class ItemsController < ApplicationController
  include CartsHelper
  
  
  # TODO: need to refactor, otherwise every new page will create a item in DB, NO GOOD !!!
  def new
    @item = Item.new
    @item.save(validate: false)
    @size_price = read_size_price_table
  end
  
  # NOT USED, because item is automatically created when user enter new page.
  # All 3 forms (refer update action) are item update actions
  def create
    # This is a photo upload, which create a new item with only image populated
    @item = Item.create(item_params)
    render 'new'     
  end
  
  def show
    @item = Item.find(params[:id])
    @size_price = read_size_price_table
    render 'new'
  end
  
  def edit
    @item = Item.find(params[:id])
    @size_price = read_size_price_table
    render 'new'
  end
  
  def art_filter
    @item = Item.find(params[:id])
    @somatic_realtime_api = "http://convert.somatic.io/api/v1.2/cdn-query"
    @somatic_api_key = "Hmzd6opl1lw0ifnwubrbz3iky8c62K"
  end
  
  # TODO: May need to refactor in future, current logic as follow
  # There are 3 update item forms in new page
  #  - photo upload form ~> new page ( current page )
  #  - crop form ~> new page ( current page )
  #  - Add to cart/Save changes button ~> cart page
  def update
    @item = Item.find(params[:id])
    @size_price = read_size_price_table
    
    # Image upload to current item, render to crop page
    if params[:image_upload]
      @item.attributes = item_params
      @item.art_filter = false
      @item.save(validate: false) # skip validation for image upload
      @crop_image = true
      render 'new'
            
    # Item added to cart or edit items in cart
    elsif params[:go_to_cart]
      if @item.update(item_params)
        # Calculate price
        @item.update_attribute(:price, calculate_price)
        # Add this item to cart
        cart = get_current_cart
        cart.items.push(@item)
        # Update quantity / price
        update_total_price_and_quantity_in_cart
      
        redirect_to cart_path
      else
        # Even it failed, save the correct fields
        @item.attributes = item_params
        @item.save(validate: false)
        render 'new' # save failed, back to item new page, may caused by missing fields
      end
    
    # Image processed by art filter
    elsif params[:art_filterred]
      @item.attributes = item_params
      @item.art_filter = true
      @item.remote_art_image_url = @item.somatic_url
      @item.save(validate: false)
      render 'new'
      
    # Image cropped, return to item new page
    elsif params[:image_cropped]
      org_image_size = Canvasking::IMAGE_ORIGINAL_SIZE_LIMIT
      crop_image_size = Canvasking::IMAGE_CROP_SIZE
      scale_scrop_cords(org_image_size, crop_image_size)
      @item.attributes = item_params
      @item.save(validate: false) # skip validation for image upload 
      render 'new'
      
    # Ajex call for +/- image quantity in cart page
    elsif params[:update_quantity]
      if params[:plus]
        @item.quantity += 1
      elsif params[:minus] && @item.quantity > 1
        @item.quantity -= 1
      end
      @item.save!
      
      # update cart price / quantity
      update_total_price_and_quantity_in_cart
      cart = get_current_cart
      render json: {quantity: @item.quantity, price: cart.price, cart_quantity: cart.quantity}
    end
      
  end
  
  def destroy
    # Update cart quantity
    cart = get_current_cart
    @item = Item.find(params[:id])
    cart.quantity -= @item.quantity
    @item.destroy
    cart.save!
    
    redirect_to cart_path
  end
  
  private
  
    def read_size_price_table
      YAML.load(File.read(Rails.root.join('business','size_price.yml')))
    end
    
    def calculate_price
      size_price = YAML.load(File.read(Rails.root.join('business','size_price.yml')))
      return size_price[params[:item][:size]]
    end
    # The x,y,w,z crops coordination passed from Jcrop are based from overview size
    # but carrierwave-jcrop gem crop process them based on origin_size (Not origin image, image after uploaded)
    # need to scale x,y,w,z according
    def scale_scrop_cords(origin_size, overview_size)
      params[:item][:image_crop_x] = ((params[:item][:image_crop_x].to_f*(origin_size.to_f/overview_size)).to_i).to_s
      params[:item][:image_crop_y] = ((params[:item][:image_crop_y].to_f*(origin_size.to_f/overview_size)).to_i).to_s
      params[:item][:image_crop_w] = ((params[:item][:image_crop_w].to_f*(origin_size.to_f/overview_size)).to_i).to_s
      params[:item][:image_crop_h] = ((params[:item][:image_crop_h].to_f*(origin_size.to_f/overview_size)).to_i).to_s
    end
    
    def item_params
      if params[:item]
        params.require(:item).permit(:image_crop_x, :image_crop_y, :image_crop_w, \
                                     :image_crop_h, :size, :price, :quantity, :image, \
                                     :depth, :border, :product_id, :art_filter, :somatic_url)
      else
        {}
      end
    end
    
    
    
    
end
