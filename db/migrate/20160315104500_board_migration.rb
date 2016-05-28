class BoardMigration < ActiveRecord::Migration
  def up
		execute " create table boards (code varchar(8) primary key, price float4 , sell float4 , buy float4 , sell_volume float4 , buy_volume float4 , open float4 , open_time varchar(5) , high float4 , high_time varchar(5) , low float4 , low_time varchar(5) , time varchar(5) , volume float4 , tick float4 , diff float4 , rate float4 , closed boolean)"
  end

  def down
		execute "drop table boards"
  end
end
