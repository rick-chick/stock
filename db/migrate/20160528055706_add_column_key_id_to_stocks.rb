class AddColumnKeyIdToStocks < ActiveRecord::Migration
  def up
		execute "alter table stocks add stock_key_id bigint"
  end

  def down
		execute "alter table stocks drop stock_key_id"
  end
end
