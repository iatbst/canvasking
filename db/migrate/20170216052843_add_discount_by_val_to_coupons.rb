class AddDiscountByValToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :discount_by_val, :boolean, default: true
  end
end
