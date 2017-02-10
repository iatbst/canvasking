class AddProcessingStatusToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :processing_status, :string
  end
end
