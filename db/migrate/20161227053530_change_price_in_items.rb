class ChangePriceInItems < ActiveRecord::Migration
  def change
    change_column :items, :price, :decimal, precision: 30, scale: 2
  end
end
