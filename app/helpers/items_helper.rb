module ItemsHelper
  def get_image_url(item, version)
    if item.art_filter
      return item.art_image.url # Art Image always return the original image
    else
      if version == "overview"
        return item.image.overview.url
      elsif version == "filter"
        return item.image.filter.url
      elsif version == "crop"
        return item.image.crop_version.url
      elsif version == "thumb"
        return item.image.thumb.url
      end
    end
  end
end
