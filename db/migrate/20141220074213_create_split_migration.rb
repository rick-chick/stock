class CreateSplitMigration < ActiveRecord::Migration
  def up
		execute "create table splits (id bigint primary key references code_dates(id), before float4, after float4, updated timestamp)"
  end

  def down
		execute "drop table splits"
  end
end
