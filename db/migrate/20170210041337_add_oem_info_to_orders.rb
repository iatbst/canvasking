class AddOemInfoToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :oem_info, :hstore, default: {}
  end
end
