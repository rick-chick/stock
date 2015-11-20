class CreateOrderMigration < ActiveRecord::Migration

  def up
    execute <<-SQL
      create table orders (
        id bigserial primary key, 
        code varchar(8),
        date timestamp, 
        no int4,
        force boolean, 
        price float4, 
        volume int8,
        trade_kbn char(1),
        updated timestamp
      )
    SQL
    #trade_kbn: 0 buy, 1 sell, 2 repay_buy, 3 repay_sell
		execute "create unique index order_table_index on orders (code, date, no)"
  end

  def down
		execute "drop table orders"
  end
end
