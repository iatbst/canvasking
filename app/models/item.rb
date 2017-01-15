class Item < ActiveRecord::Base
  belongs_to :product
  belongs_to :cart
  belongs_to :order
  mount_uploader :image, ImageUploader
  mount_uploader :art_image, ImageUploader
  crop_uploaded :image
  
  # Validations
  validates :product_id, presence: {message: "Please choose a product"}
  validates :size, presence: {message: "Please choose a size"}
  validates :depth, presence: {message: "Please choose a depth"}, if: :canvas_is_selected?
  validates :border, presence: {message: "Please choose a border style"}, if: :canvas_is_selected?
  validates :image, presence: {message: "Please upload a image"}
  validates :frame_id, presence: {message: "Please choose a frame"}, if: :frame_is_selected?
  validates :mat, presence: {message: "Please choose a mat"}, if: :frame_is_selected?
  
  
  
  def canvas_is_selected?
    Product.find(product_id).name.include?("canvas")
  end
  
  def frame_is_selected?
    Product.find(product_id).name.include?("frame")
  end
end
