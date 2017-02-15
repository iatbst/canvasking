class AddColConditionToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :condition, :hstore, default: {}
  end
end
