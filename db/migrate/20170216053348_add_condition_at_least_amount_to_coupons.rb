class AddConditionAtLeastAmountToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :condition_at_least_amount, :integer
  end
end
