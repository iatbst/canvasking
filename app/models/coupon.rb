class Coupon < ActiveRecord::Base
  belongs_to :user
  
  # Validation
  validates :code, presence: {message: "Code can't be empty!"}
  validates :code, uniqueness: {message: "Code is already used!"}
  validates :description, presence: {message: "Description can't be empty!"}
  validates :exp_date, presence: {message: "Expire date can't be empty!"}
  validates :discount_val, presence: {message: "Discount value/Percentage can't be empty!"}, if: :discount_ptg_nil?
  validates :discount_ptg, presence: {message: "Discount value/Percentage can't be empty!"}, if: :discount_val_nil?
end

def discount_val_nil?
  discount_val.nil?
end

def discount_ptg_nil?
  discount_ptg.nil?
end