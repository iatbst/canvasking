class AddOptionPricesToItems < ActiveRecord::Migration
  def change
    add_column :items, :option_prices, :hstore, default: {}
  end
end
