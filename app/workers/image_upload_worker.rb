class ImageUploadWorker
  include Sidekiq::Worker

  def perform(image_file_path, item_id, field)
    # Save Images to S3
    item = Item.find(item_id)
    File.open(image_file_path) do |f|
      if field == 'image'
        item.image = f
      else 
        item.art_image = f
      end
    end
    item.save
  end
  
end
