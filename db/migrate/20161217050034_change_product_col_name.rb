class ChangeProductColName < ActiveRecord::Migration
  def change
    rename_column 'products', 'type', 'name' 
  end
end
