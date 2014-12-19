class CreateSplitMigration < ActiveRecord::Migration
  def up
		execute "create table splits (code varchar(8), date char(8), before float4, after float4, primary key (code, date))"
  end

  def down
		execute "drop table splits"
  end
end
