class RemoveConditionFromCoupons < ActiveRecord::Migration
  def change
    remove_column :coupons, :condition
  end
end
