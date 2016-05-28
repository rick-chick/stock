class DropColumnIdFromStocks < ActiveRecord::Migration
  def up
		execute "alter table stocks drop id"
  end

  def down
		execute "alter table stocks add id bigint"
  end
end
