class AddColDiscountPriceAndCouponToCarts < ActiveRecord::Migration
  def change
    add_column :carts, :discount_price, :decimal, precision: 30, scale: 2
    add_reference :carts, :coupon, index: true
    add_foreign_key :carts, :coupons
  end
end
