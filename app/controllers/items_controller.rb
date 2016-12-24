class ItemsController < ApplicationController
  include CartsHelper
  
  
  def new
    @item = Item.create
  end
  
  # Ugly, need to refactor !!!
  def create
    if params[:add_to_cart]
      if ready_to_cart
        @item = Item.find(params[:item][:id])
        @item.width = params[:item][:width]
        @item.height = params[:item][:height]
        @item.price = params[:item][:price]
        @item.product_id = params[:item][:product]
        @item.depth = params[:item][:depth]
        @item.border = params[:item][:border]
        @item.save!
        render 'show'      
      else
        # Some attributes is missing, return back to item new page
        if params[:item][:id].empty?
          redirect_to new_item_path
        else
          @item = Item.find(params[:id])
          render 'new'          
        end
      end
    else
      # This is a photo upload, which create a new item with only image populated
      @item = Item.create(item_params)
      render 'new'     
    end
  end
  
  def show
    
  end
  
  def edit
    @item = Item.find(params[:id])
    render 'edit'
  end
  
  def update
    @item = Item.find(params[:id])
    
    # Image upload to current item, so stay in previous page, new/edit page
    if params[:image_upload]
      @item.update(item_params)
      render 'new'
      
    # First time item added to cart
    elsif params[:add_to_cart]
      parse_width_height_price_from_width_or_height
      @item.quantity = 1
      @item.update(item_params)
      
      # Add this item to cart
      cart = get_current_cart
      cart.items.push(@item)
      redirect_to cart_path
    end
      
  end
  
  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    
    redirect_to cart_path
  end
  
  private
    
    def item_params
      params.require(:item).permit(:width, :height, :price, :quantity, :image, :depth, :border, :product_id)
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
    
    def ready_to_cart
      return  params[:item] && \
              params[:item][:width] && \
              params[:item][:height] && \
              params[:item][:price] && \
              params[:item][:image] && \
              params[:item][:depth] && \
              params[:item][:border] && \
              params[:item][:product] && \
              !params[:item][:id].empty?
    end
end
