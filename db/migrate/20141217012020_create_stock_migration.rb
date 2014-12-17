class CreateStockMigration < ActiveRecord::Migration
  def up
		execute "create table stocks ( code varchar(8), date char(8), open float4, high float4, low float4, close float4, adjusted float4, volume int8 , primary key (code, date));"
  end

  def down
		execute "drop table stocks"
  end
end
