class TmpImageRemoveWorker
  include Sidekiq::Worker

  def perform(image_file_path, item_id, field, force=false)
    # Occasionally, item maybe destroyed before running sidekiq jobs
    # Eg: item deletion
    begin
      item = Item.find(item_id)
    rescue ActiveRecord::RecordNotFound => e
    end
    
    # Transform file path for production and stage
    # We can't use `release/xxxxxxx` as part of this file path, as we only keep latest 5 releases
    # Using shared folder path instead, because all the releases link these upload tmp files from share folder
    # Eg, 
    # Transform 
    #   file path : `/home/deploy/canvasking/releases/20170217062513/public/uploads/tmp/1487313239-9835-2414/644489_485813851478004_1140509276_n.jpg`
    # To
    #   file path : `/home/deploy/canvasking/shared/public/uploads/tmp/1487313239-9835-2414/644489_485813851478004_1140509276_n.jpg`
    if Rails.env == 'production' || Rails.env == 'staging'
      image_file_path = image_file_path.split('/')
      image_file_path.delete_at(5)
      image_file_path[4] = 'shared'
      image_file_path = image_file_path.join('/')
    end
    
    # Clear tmp files on /Upload/tmp after image uploaded 10 min later
    # Normally if files are not in remote S3 for any reasons, local files should not be removed for backup
    # purpose, unless `force` is `true`
    if (field == 'image' && ( force || item.nil? || !item.image.file.nil?)) || \
       (field == 'art_image' && ( force || item.nil? || !item.art_image.file.nil?))
       folder = image_file_path.split('/')
       folder.pop()
       folder_path = folder.join('/')
       FileUtils.remove_dir(folder_path)
       
       # clear tmp field
       if item
          if (field == 'image')
              item.update_attribute('image_tmp_paths', {})
          else
              item.update_attribute('art_image_tmp_paths', {})
          end
       end 
    end

  end
  
end
