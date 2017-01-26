# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :fog

  before :store, :remember_cache_id
  after :store, :delete_tmp_dir

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # WARN: This is the process eat up your upload times
  # process resize_to_fit: [3000, 3000]
  process crop: :image
  
  
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files: 
  version :filter do
    resize_to_fit(600, 800)
  end

  version :overview, :from_version => :filter do
    resize_to_fit(500, 500)
  end
   
  version :cart, :from_version => :overview do
    resize_to_fit(450, 450)
  end

  version :crop_version, :from_version => :cart do
    attr_accessor :url
    resize_to_fit(450, 450)
  end
   
  
  version :thumb, :from_version => :cart do
    resize_to_fit(200, 200)
  end


  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
     %w(jpg jpeg gif png jpg_or_png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "#{original_filename.split('.')[0]}.jpg" if original_filename
  end

  def move_to_cache
    true
  end
  
  def move_to_store
    true
  end


  # store! nil's the cache_id after it finishes so we need to remember it for deletion
  def remember_cache_id(new_file)
    @cache_id_was = cache_id
    @current_path_was = current_path
  end

  def delete_tmp_dir(new_file)
    # make sure we don't delete other things accidentally by checking the name pattern
    tmp_folder_path = File.join(root, cache_dir, @cache_id_was)
    if @cache_id_was.present? && File.exists?(@current_path_was)
      FileUtils.rm_f(@current_path_was)
      # If all files gone, delete the folder
      if Dir.entries(tmp_folder_path).size <= 2
        FileUtils.remove_dir(tmp_folder_path)
      end
    end
  end

  
end
