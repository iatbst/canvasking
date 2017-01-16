module ItemsHelper
  def get_image_url(item, version)
    if item.art_filter
      if item.art_image.file.nil?
        return item.somatic_url # image not upload completed yet, render image use somatic url
      else
        if version == "overview"
          return item.art_image.overview.url
        elsif version == "filter"
          return item.art_image.filter.url
        elsif version == "crop"
          return item.art_image.crop_version.url
        elsif version == "thumb"
          return item.art_image.thumb.url
        else
          return item.art_image.url
        end
      end
    else
      if version == "overview"
        return item.image.overview.url
      elsif version == "filter"
        return item.image.filter.url
      elsif version == "crop"
        return item.image.crop_version.url
      elsif version == "thumb"
        return item.image.thumb.url
      else
        return item.image.url
      end
    end
  end
  
  def image_is_framed(item)
    !item.image.file.nil? && !item.product.nil? && item.product.name.include?('frame')
  end
  
  def image_is_framed_with_type(item, type)
     image_is_framed(item) && !item.frame_id.nil? && Frame.find(item.frame_id).name.include?(type)
  end
  
  def image_is_triptych(item)
    !item.image.file.nil? && !item.product.nil? && item.product.name.include?('triptych')
  end
end
