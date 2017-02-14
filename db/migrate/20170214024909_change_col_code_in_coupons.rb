class ChangeColCodeInCoupons < ActiveRecord::Migration
  def change
    change_column :coupons, :code, :string, unique: true
    add_column :coupons, :used_count, :integer
  end
end
