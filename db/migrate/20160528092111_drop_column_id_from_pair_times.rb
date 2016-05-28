class DropColumnIdFromPairTimes < ActiveRecord::Migration
  def up
		execute "alter table pair_times drop id"
  end

  def down
		execute "alter table pair_times add id bigint"
  end
end
