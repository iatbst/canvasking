class Item < ActiveRecord::Base
  belongs_to :product
  belongs_to :cart
  belongs_to :order
  mount_uploader :image, ImageUploader
  crop_uploaded :image
end
