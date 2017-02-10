class ChangeColProcessingStatusInOrders < ActiveRecord::Migration
  def change
    change_column :orders, :processing_status, 'integer USING CAST(processing_status AS integer)'
  end
end
