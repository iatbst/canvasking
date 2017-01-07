module ItemsHelper
  def get_image_url(item, version)
    if item.art_filter
      if item.art_image.file.nil?
        return item.somatic_url # image not upload completed yet, render image use somatic url
      else
        return item.art_image.url # image uploaded done, use S3 url
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
      end
    end
  end
end
