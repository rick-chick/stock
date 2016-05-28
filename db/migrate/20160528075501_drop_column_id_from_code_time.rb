class DropColumnIdFromCodeTime < ActiveRecord::Migration
  def up
		execute "alter table code_times drop id"
  end

  def down
		execute "alter table code_times add id bigint"
  end
end
