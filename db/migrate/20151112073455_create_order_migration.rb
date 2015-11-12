class CreateOrderMigration < ActiveRecord::Migration

  def up
    execute <<-SQL
      create table orders (
        id bigserial primary key, 
        code varchar(8),
        date date, 
        no int4,
        force boolean, 
        price float4, 
        volume int8, 
        contracted_price float4, 
        contracted_volume int8
      )
    SQL
		execute "create unique index order_table_index on orders (code, date, no)"
  end

  def down
		execute "drop table orders"
  end
end
