class ItemMessagesController < ApplicationController

  def create
    @item = Item.find(params[:item_id])

    @message = @item.item_messages.create(message_params)
    @item.update(item_params)
    flash[:notice] = "Thanks for your feedbacks !"
    if @item.rate > 4
      flash[:rate] = "We feel so great today you like our product:)"
    elsif @item.rate == 3
      flash[:rate] = "We will improve our product for you."
    else
      flash[:rate] = "We feel sorry to let you down, please send us on support@canvasking.com for replacement or refund"
    end
  
    redirect_to orders_path
  end
 
  private
    def message_params
      params.require(:item_message).permit(:message, :item)
    end
 
    def item_params
      params.require(:item_message).require(:item).permit(:received, :rate)
    end
    
end
