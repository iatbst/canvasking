class Order < ActiveRecord::Base
  belongs_to :user
  has_many :items
  
  # Validations
  validates :shipping_full_name, presence: {message: "Please fill in your full name."}
  validates :shipping_address_1, presence: {message: "Please fill in your street address."}
  validates :shipping_city, presence: {message: "Please fill in your city name."}
  validates :shipping_state, presence: {message: "Please select a state."}
  validates :shipping_country, presence: {message: "Please select a countyr."}
  validates :shipping_zip, presence: {message: "Please fill in your post zip code."}
end
