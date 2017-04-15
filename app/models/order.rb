class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :state
  belongs_to :country
  belongs_to :coupon
  has_many :items
  
  # Validations
  validates :shipping_full_name, presence: {message: "Please fill in your full name."}
  validates :shipping_address_1, presence: {message: "Please fill in your street address."}
  validates :shipping_city, presence: {message: "Please fill in your city name."}
  validates :state_id, presence: {message: "Please select a state."}
  validates :country_id, presence: {message: "Please select a country."}
  validates :shipping_zip, presence: {message: "Please fill in your post zip code."}
  validates :guest_email, presence: {message: "Please fill in contact email."}
  validates_format_of :guest_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, :message => "Invalid email format."
  validates :shipping_phone, presence: {message: "Please fill in contact phone in case first delivery failed."}

end
