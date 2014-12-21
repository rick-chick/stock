class CreateStockMigration < ActiveRecord::Migration
  def up
		execute "create table stocks ( id bigserial primary key , open float4, high float4, low float4, close float4, adjusted float4, volume int8, updated timestamp);"
  end

  def down
		execute "drop table stocks"
  end
end
