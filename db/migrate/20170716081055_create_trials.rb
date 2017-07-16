class CreateTrials < ActiveRecord::Migration
  def change
    create_table :trials do |t|
      t.string :status
      t.references :user, index: true
      t.string :vpn_server

      t.timestamps null: false
    end
    add_foreign_key :trials, :users
  end
end
