class TmpImageRemoveWorker
  include Sidekiq::Worker

  def perform(image_file_path, item_id, field, force=false)
    item = Item.find(item_id)
    
    # Clear tmp files on /Upload/tmp after image uploaded 10 min later
    # Normally if files are not in remote S3 for any reasons, local files should not be removed for backup
    # purpose, unless `force` is `true`
    if (field == 'image' && (!item.image.file.nil?) || force) || \
       (field == 'art_image' && (!item.art_image.file.nil? || force))
       folder = image_file_path.split('/')
       folder.pop()
       folder_path = folder.join('/')
       FileUtils.remove_dir(folder_path)
       
       # clear tmp field
       if (field == 'image')
          item.update_attribute('image_tmp_paths', {})
       else
          item.update_attribute('art_image_tmp_paths', {})
       end 
    end

  end
  
end
