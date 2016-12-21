class ItemsController < ApplicationController
  
  
  def new
    @item = Item.new
  end
  
  def create
    @item = Item.create(item_params)
    render 'new'
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
end
