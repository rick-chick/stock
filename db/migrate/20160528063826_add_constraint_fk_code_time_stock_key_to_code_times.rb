class AddConstraintFkCodeTimeStockKeyToCodeTimes < ActiveRecord::Migration
  def up
		execute(<<-SQL
      alter table code_times 
      add constraint fk_code_time_stock_key 
      foreign key (stock_key_id) 
      references stock_keys(id)
      on delete cascade
    SQL
    )
  end

	def down
		execute('alter table code_times drop constraint fk_code_time_stock_key')
	end
end
