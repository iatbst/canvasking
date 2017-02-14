class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :code
      t.boolean :public, default: true
      t.references :user, index: true
      t.decimal :discount_val
      t.integer :discount_ptg
      t.boolean :used, default: false
      t.datetime :exp_date
      t.string :description

      t.timestamps null: false
    end
    add_foreign_key :coupons, :users
  end
end
