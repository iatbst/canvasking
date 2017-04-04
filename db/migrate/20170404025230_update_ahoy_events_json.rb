class UpdateAhoyEventsJson < ActiveRecord::Migration
  def change
    remove_column :ahoy_events, :properties
    add_column :ahoy_events, :properties, :json
  end
end
