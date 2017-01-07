class ImageUploadJob < ActiveJob::Base
  queue_as :default

  def perform(item)
    # Do something later
    item.remote_art_image_url = item.somatic_url
    item.save(validate: false)
  end
end
