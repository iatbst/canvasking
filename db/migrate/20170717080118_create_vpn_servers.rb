class CreateVpnServers < ActiveRecord::Migration
  def change
    create_table :vpn_servers do |t|
      t.string :ip
      t.references :user, index: true
      t.date :expire_date
      t.boolean :trial
      t.boolean :active

      t.timestamps null: false
    end
    add_foreign_key :vpn_servers, :users
  end
end
