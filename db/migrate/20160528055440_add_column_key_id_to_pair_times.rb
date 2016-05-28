class AddColumnKeyIdToPairTimes < ActiveRecord::Migration
  def up
		execute "alter table pair_times add stock_key_id bigint"
  end

  def down
		execute "alter table pair_times drop stock_key_id"
  end
end
