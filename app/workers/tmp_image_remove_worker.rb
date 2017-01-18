class TmpImageRemoveWorker
  include Sidekiq::Worker

  def perform(image_file_path, item_id, field)
    item = Item.find(item_id)
    
    # Clear tmp files on /Upload/tmp after image uploaded 10 min later
    if (field == 'image' && !item.image.file.nil?) || \
       (field == 'art_image' && !item.art_image.file.nil?)
       folder = image_file_path.split('/')
       folder.pop()
       folder_path = folder.join('/')
       FileUtils.remove_dir(folder_path)
    end
    
  end
  
end
