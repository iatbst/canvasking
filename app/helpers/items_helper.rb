module ItemsHelper
  def get_image_url(item, version, options = {})
    if item.art_filter || options['art_effect']
      if !item.art_image.file.nil? && !item.art_image.url.include?('jpg_or_png')
        if version == "overview"
          return item.art_image.overview.url
        elsif version == "filter"
          return item.art_image.filter.url
        elsif version == "cart"
          return item.art_image.cart.url
        elsif version == "thumb"
          return item.art_image.thumb.url
        else
          return item.art_image.url
        end
      else
        return item.art_image_tmp_paths[version]
      end
    else
      # If image not on S3 yet, return local tmp image
      if !item.image.file.nil?
        if version == "filter"
            return item.image.filter.url
        elsif version == "cart"
          return item.image.cart.url
        elsif version == "overview"
          return item.image.overview.url
        elsif version == "thumb"
          return item.image.thumb.url
        else
          return item.image.url
        end       
      else
        return item.image_tmp_paths[version]
      end

    end
  end
  
  def image_is_framed(item)
    !item.product.nil? && item.product.name.include?('frame')
  end
  
  def image_is_framed_with_type(item, type)
     image_is_framed(item) && !item.frame_id.nil? && Frame.find(item.frame_id).name.include?(type)
  end
  
  def image_is_triptych(item)
    !item.product.nil? && item.product.name.include?('triptych')
  end
  
    # def crop_local_tmp_files(item, versions, cords)
      # if versions.empty?
        # return
      # end
      # origin_file_path = "#{Rails.root}/public#{item.image_tmp_paths['origin']}"
      # crop_x, crop_y, crop_w, crop_h = get_cords_for_origin_version(cords) 
      # image = MiniMagick::Image.open(origin_file_path)
      # image.crop("#{crop_w}x#{crop_h}!+#{crop_x}+#{crop_y}")
      # versions.each do |ver|
          # abs_path = "#{Rails.root}/public#{item.image_tmp_paths[ver]}"
          # width, height = get_resize_width_and_height(ver)
          # image.resize("#{width}x#{height}")
          # image.write(abs_path)
      # end
    # end
#     
    # def get_resize_width_and_height(ver)
      # if ver == "cart"
        # return 450, 450
      # elsif ver == "overview"
        # return 300, 300
      # elsif ver == "filter"
        # return 600, 800
      # elsif ver == "thumb"
        # return 200, 200
      # else
        # return 3000, 3000
      # end     
    # end
#     
    # def get_cords_for_origin_version(cords)
      # ratio = Canvasking::IMAGE_VER_ORI/Canvasking::IMAGE_VER_CROP.to_f
      # return ((cords[0]).to_i*ratio).to_i , \
             # ((cords[1]).to_i*ratio).to_i , \
             # ((cords[2]).to_i*ratio).to_i , \
             # ((cords[3]).to_i*ratio).to_i
    # end
    
end
