class CreateShippingAddresses < ActiveRecord::Migration
  def change
    create_table :shipping_addresses do |t|
      t.references :user, index: true
      t.string :name
      t.string :address_1
      t.string :address_2
      t.string :city
      t.references :state, index: true
      t.references :country, index: true
      t.string :zip

      t.timestamps null: false
    end
    add_foreign_key :shipping_addresses, :users
    add_foreign_key :shipping_addresses, :states
    add_foreign_key :shipping_addresses, :countries
  end
end
