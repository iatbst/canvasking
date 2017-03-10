class AddJobsIdInItems < ActiveRecord::Migration
  def change
    add_column :items, :jobs, :hstore, default: {}
  end
end
