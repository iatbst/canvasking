class ItemsController < ApplicationController
  include CartsHelper
  
  
  # TODO: need to refactor, otherwise every new page will create a item in DB, NO GOOD !!!
  def new
    @item = Item.create
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
    render 'new'
  end
  
  def edit
    @item = Item.find(params[:id])
    render 'new'
  end
  
  # TODO: May need to refactor in future, current logic as follow
  # There are 3 update item forms in new page
  #  - photo upload form ~> new page ( current page )
  #  - crop form ~> new page ( current page )
  #  - Add to cart/Save changes button ~> cart page
  def update
    @item = Item.find(params[:id])
    
    # Image upload to current item, render to crop page
    if params[:image_upload]
      @item.update(item_params)
      @file_upload = true
      render 'new'
            
    # Item added to cart
    elsif params[:add_to_cart]
      parse_width_height_price_from_width_or_height
      @item.quantity = 1
      @item.update(item_params)
      
      # Add this item to cart
      cart = get_current_cart
      cart.items.push(@item)

      redirect_to cart_path
      
    # Image cropped, return to item new page
    elsif params[:image_cropped]
      scale_scrop_cords(3000, 400)
      @item.update(item_params)  
      render 'new'
    end
      
  end
  
  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    
    redirect_to cart_path
  end
  
  private
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
      params.require(:item).permit(:image_crop_x, :image_crop_y, :image_crop_w, :image_crop_h, :width, :height, :price, :quantity, :image, :depth, :border, :product_id)
    end
    
    # An ugly way to process passed in width value for 3 fields: width/height/price
    def parse_width_height_price_from_width_or_height
      if !params[:item][:height].empty?
        combination = params[:item][:height]
        params[:item][:width] = combination.split(",")[0]
        params[:item][:height] = combination.split(",")[1]
        params[:item][:price] = combination.split(",")[2]      
      else
        combination = params[:item][:width]
        params[:item][:width] = combination.split(",")[0]
        params[:item][:height] = combination.split(",")[1]
        params[:item][:price] = combination.split(",")[2]        
      end
    end
    
    
end
