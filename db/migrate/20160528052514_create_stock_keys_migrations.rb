class CreateStockKeysMigrations < ActiveRecord::Migration
  def up
		execute "create table stock_keys ( id bigserial primary key, updated timestamp );"
  end

  def down
		execute "drop table stock_keys"
  end
end
