class ChangeDateTypeInServers < ActiveRecord::Migration
  def change
    change_column :vpn_servers, :expire_date, :datetime
  end
end
