class Item < ActiveRecord::Base
  attr_accessor :time_to_save
  belongs_to :product
  belongs_to :cart
  belongs_to :order
  mount_uploader :image, ImageUploader
  mount_uploader :art_image, ImageUploader
  crop_uploaded :image
  
  # Validations
  validates :product_id, presence: {message: "Please choose a product"}, if: :image_is_uploaded?
  validates :size, presence: {message: "Please choose a size"}, if: :product_is_selected?
  validates :depth, presence: {message: "Please choose a depth"}, if: :canvas_is_selected?
  validates :border, presence: {message: "Please choose a border style"}, if: :canvas_is_selected?
  validates :image, presence: {message: "Please upload a image"}, if: :time_to_save?
  validates :frame_id, presence: {message: "Please choose a frame"}, if: :frame_is_selected?
  validates :mat, presence: {message: "Please choose a mat"}, if: :frame_is_selected?
  
  def time_to_save?
   time_to_save 
  end
  
  def image_is_uploaded?
    time_to_save && !image.file.nil?
  end
  
  def product_is_selected?
    time_to_save && !product_id.nil?  
  end
  
  def canvas_is_selected?
    time_to_save && !product_id.nil? && Product.find(product_id).name.include?("canvas")
  end
  
  def frame_is_selected?
    time_to_save && !product_id.nil? && Product.find(product_id).name.include?("frame")
  end
end
