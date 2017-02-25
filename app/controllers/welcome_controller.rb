class WelcomeController < ApplicationController
  def index

    # used for play around section
    @somatic_realtime_api = ENV["somatic_api_url"]
    @somatic_api_key = ENV["somatic_api_key"]
    @website_url = ENV['website_url']
  end

  def image_upload
    item = Item.new
    item.save
    item.attributes = image_params
    prepare_tmp_image_paths(item, 'image_tmp_paths')
    
    # Create worker to remove tmp file later
    origin_tmp_file_path = "#{Rails.root}/public#{item.image_tmp_paths['origin']}"
    #TmpImageRemoveWorker.perform_in(Canvasking::IMAGE_TMP_CACHE_TIME.hours, origin_tmp_file_path, item.id, 'image', force=true)
      
    # In development, save images to S3; In prod/staging, S3 store is delayed until 
    # button `Order A Canvas On This Style` clicked
    if Rails.env == "development"
      item.save
      render json: {'status'=> 'SUCCESS','item_id'=> item.id,
                    'image_url'=> item.image.overview.url }
    else
      render json: {'status'=> 'SUCCESS','item_id'=> item.id,
                    'image_url'=> item.image_tmp_paths['overview'] }    
    
    end
    
  end

  private

  def image_params
    params.require(:item).permit(:image)
  end

  
  def prepare_tmp_image_paths(item, col)
    paths = {}
    if col == 'image_tmp_paths'
      paths['origin'] = item.image.current_path.split('public')[1]
      paths['filter'] = item.image.filter.current_path.split('public')[1]
      paths['cart'] = item.image.cart.current_path.split('public')[1]
      paths['overview'] = item.image.overview.current_path.split('public')[1]
      paths['thumb'] = item.image.thumb.current_path.split('public')[1]
    elsif col == 'art_image_tmp_paths'
      paths['origin'] = item.art_image.current_path.split('public')[1]
      paths['filter'] = item.art_image.filter.current_path.split('public')[1]
      paths['cart'] = item.art_image.cart.current_path.split('public')[1]
      paths['overview'] = item.art_image.overview.current_path.split('public')[1]
      paths['thumb'] = item.art_image.thumb.current_path.split('public')[1]
    end
    item.update_column(col, paths)
  end

end
