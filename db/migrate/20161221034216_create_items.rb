class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :product, index: true
      t.integer :height
      t.integer :width
      t.string :image
      t.decimal :price
      t.integer :quantity

      t.timestamps null: false
    end
    add_foreign_key :items, :products
  end
end
