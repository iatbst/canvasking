class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :shipping_full_name
      t.string :shipping_address_1
      t.string :shipping_address_2
      t.string :shipping_city
      t.string :shipping_country
      t.string :shipping_state
      t.string :shipping_zip
      t.string :shipping_phone
      
      t.timestamps null: false
    end
  end
end
