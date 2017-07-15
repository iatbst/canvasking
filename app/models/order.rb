class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :state
  belongs_to :country
  belongs_to :coupon
  has_many :items
  
  # Validations
  validates :guest_email, presence: {message: "Please fill in contact email."}
  validates_format_of :guest_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, :message => "Invalid email format."
  

end
