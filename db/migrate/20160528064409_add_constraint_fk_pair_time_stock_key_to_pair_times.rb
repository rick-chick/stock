class AddConstraintFkPairTimeStockKeyToPairTimes < ActiveRecord::Migration
  def up
		execute(<<-SQL
      alter table pair_times 
      add constraint fk_pair_time_stock_key 
      foreign key (stock_key_id) 
      references stock_keys(id)
      on delete cascade
    SQL
           )
  end

	def down
		execute('alter table pair_times drop constraint fk_pair_time_stock_key')
	end
end
