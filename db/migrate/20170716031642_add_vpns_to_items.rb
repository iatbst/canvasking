class AddVpnsToItems < ActiveRecord::Migration
  def change
    add_column :items, :vpn_desc, :string
    add_column :items, :vpn_server, :string
    add_column :items, :vpn_exp_date, :date
  end
end
