class Item < ActiveRecord::Base
  belongs_to :product
  belongs_to :cart
  mount_uploader :image, ImageUploader
end
