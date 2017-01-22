class CreateItemMessages < ActiveRecord::Migration
  def change
    create_table :item_messages do |t|
      t.text :message
      t.references :item, index: true

      t.timestamps null: false
    end
    add_foreign_key :item_messages, :items
  end
end
