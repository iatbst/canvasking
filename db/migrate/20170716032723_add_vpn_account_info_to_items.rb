class AddVpnAccountInfoToItems < ActiveRecord::Migration
  def change
    add_column :items, :vpn_username, :string
    add_column :items, :vpn_password, :string
    add_column :items, :vpn_phrase, :string
  end
end
