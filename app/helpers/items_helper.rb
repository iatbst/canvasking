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
      elsif item.image.file.nil?
        return '/canvas_placeholder.png'
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
      elsif item.art_image.file.nil?
        return '/canvas_placeholder.png'
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

  def art_image_is_uploaded(item)
    !item.art_image.file.nil? || !item.art_image_tmp_paths['origin'].nil?
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
  
  def hide_image_upload_section?(new_action, show, save_fail, item)
    return !( new_action || \
              (save_fail && !image_is_uploaded(item)) || \
              (show && !image_is_uploaded(item)) )  
  end
  
  def hide_filter_section?(params)
    return !( params[:image_cropped] )
  end
  
  def hide_filter_done_section?(new_action, params)
    return !hide_filter_section?(params) || new_action
  end
  
  def hide_products_section?(edit, show, params, save_fail, item)
    return !( edit || \
              params[:art_filterred] || \
              save_fail || \
              (show && image_is_uploaded(item)))
  end

  def hide_size_section?(edit, show, save_fail, params, item)
    return !( edit || \
              (save_fail && item.product) || \
              (params[:art_filterred] && item.product) || \
              (show && image_is_uploaded(item) && item.product ))
  end
  
  def hide_canvas_options_section?(item)
    return !(item.product && item.product.name.include?("canvas"))
  end
  
  def hide_frame_options_section?(item)
    return !(item.product && item.product.name.include?("frame"))
  end
  
  def hide_summary_section?(edit, show, save_fail, params, item)

    return !( edit || \
            (show && item.size) || \
            (save_fail && item.size) || \
            (params[:art_filterred] && item.size))
  end
end
