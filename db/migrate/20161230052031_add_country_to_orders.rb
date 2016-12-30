class AddCountryToOrders < ActiveRecord::Migration
  def change
    add_reference :orders, :country, index: true
    add_foreign_key :orders, :countries
  end
end
