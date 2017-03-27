class ItemMessagesController < ApplicationController

  def create
    @item = Item.find(params[:item_id])

    @message = @item.item_messages.create(message_params)
    @item.update(item_params)
    flash[:item_messages_note] = true
    if !@item.rate.nil?
      if @item.rate > 4
        flash[:item_messages_note_content] = "We feel so great today you like our product :)"
      elsif @item.rate == 3
        flash[:item_messages_note_content] = "We will improve our product for you !"
      else
        flash[:item_messages_note_content] = "We feel sorry to let you down, please send us on support@canvasking.com for replacement or refund."
      end
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
