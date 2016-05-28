class AddConstraintFkStockStockKeyToStocks < ActiveRecord::Migration
  def up
		execute(<<-SQL
      alter table stocks 
      add constraint fk_stock_stock_key 
      foreign key (stock_key_id) 
      references stock_keys(id)
      on delete cascade
    SQL
           )
  end

	def down
		execute('alter table stocks drop constraint fk_stock_stock_key')
	end
end
