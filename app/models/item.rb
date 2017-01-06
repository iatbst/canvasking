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
  validates :depth, presence: {message: "Please choose a depth"}
  validates :border, presence: {message: "Please choose a border style"}
  validates :image, presence: {message: "Please upload a image"}
end
