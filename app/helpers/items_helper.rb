module ItemsHelper
  
  def get_image_url(item, version, options = {})
    if options['art_effect']
      return get_art_image_url(item, version)
    elsif options['no_effect']
      return get_normal_image_url(item, version)
    elsif item.art_filter
      return get_art_image_url(item, version)
    else
      return get_normal_image_url(item, version)
    end
  end

  def get_normal_image_url(item, version)
      # If image is still cached in local tmp, use it first, if not, use the one on S3
      if !item.image_tmp_paths.empty?
        return item.image_tmp_paths[version]
      else
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
      end

  end
  
  def get_art_image_url(item, version)
    
      if !item.art_image_tmp_paths.empty?
        return item.art_image_tmp_paths[version]
      else
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
      end

  end
  
  def image_is_uploaded(item)
    !item.image.file.nil? || !item.image_tmp_paths.empty?
  end
  
  def image_is_framed(item)
    !item.product.nil? && item.product.name.include?('frame')
  end
  
  def image_is_framed_with_type(item, type)
     image_is_framed(item) && !item.frame_id.nil? && Frame.find(item.frame_id).name.include?(type)
  end
  
  def image_is_matted(item)
    !(item.mat.nil? || item.mat.to_i == 0)
  end
  
  def image_is_triptych(item)
    !item.product.nil? && item.product.name.include?('triptych')
  end
  
  def add_frame_and_mat_class(item, page)
    classes = ""
    if image_is_framed(item)
      if image_is_framed_with_type(item, "black")
        classes += "image_black_frame_in_#{page}"
      elsif image_is_framed_with_type(item, "white")
        classes += "image_white_frame_in_#{page}"
      else
        classes += "image_brown_frame_in_#{page}"
      end
      
      if image_is_matted(item)
        classes += " image_frame_mat_in_#{page}"
      end
    end
    
    return classes
  end

  
end
