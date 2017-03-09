class ChangeDiscountPtgToDecimalInCoupons < ActiveRecord::Migration
  def change
    change_column :coupons, :discount_ptg, :decimal, precision: 20, scale: 2
  end
end
