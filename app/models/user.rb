class User < ActiveRecord::Base
  include CartsHelper
  
  has_one :cart
  has_many :orders
  has_many :coupons
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  
  

end
