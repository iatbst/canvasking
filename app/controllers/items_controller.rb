class ItemsController < ApplicationController
  
  
  def new
    @item = Item.new
  end
  
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
  
  def update
    @item = Item.find(params[:id])
 
    if @item.update(item_params)
      render 'new'
    else
      redirect_to new_item_path
    end
  end
  
  
  
  private
    def item_params
      params.require(:item).permit(:width, :height, :price, :quantity, :image, {image: []})
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
