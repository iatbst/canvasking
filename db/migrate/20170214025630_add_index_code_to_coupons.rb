class AddIndexCodeToCoupons < ActiveRecord::Migration
  def change
    add_index :coupons, :code, :unique => true
  end
end
