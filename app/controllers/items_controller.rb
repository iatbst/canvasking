class ItemsController < ApplicationController
  include CartsHelper
  
  
  # TODO: need to refactor, otherwise every new page will create a item in DB, NO GOOD !!!
  def new
    @item = Item.create
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
      @item.update(item_params)
      @file_upload = true
      render 'new'
            
    # Item added to cart or edit items in cart
    elsif params[:go_to_cart]
      @item.price = calculate_price
      @item.update(item_params)
      
      # Add this item to cart
      cart = get_current_cart
      cart.items.push(@item)

      redirect_to cart_path
      
    # Image cropped, return to item new page
    elsif params[:image_cropped]
      scale_scrop_cords(3000, 300)
      @item.update(item_params)  
      render 'new'
    
    elsif params[:update_quantity]
      if params[:plus]
        @item.quantity += 1
      elsif params[:minus] && @item.quantity > 1
        @item.quantity -= 1
      end
      @item.save!
      # update cart price
      cart = get_current_cart
      update_total_price_in_cart(cart)
      render json: {quantity: @item.quantity, price: cart.price}
    end
      
  end
  
  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    
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
      params.require(:item).permit(:image_crop_x, :image_crop_y, :image_crop_w, :image_crop_h, :size, :price, :quantity, :image, :depth, :border, :product_id)
    end
    
    
    
    
end
