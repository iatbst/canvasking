class ChangeColUsedCountToCoupons < ActiveRecord::Migration
  def change
    change_column :coupons, :used_count, :integer, default: 0
  end
end
