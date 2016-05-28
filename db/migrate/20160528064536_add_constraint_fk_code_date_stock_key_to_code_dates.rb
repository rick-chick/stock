class AddConstraintFkCodeDateStockKeyToCodeDates < ActiveRecord::Migration
  def up
		execute(<<-SQL
      alter table code_dates 
      add constraint fk_code_date_stock_key 
      foreign key (stock_key_id) 
      references stock_keys(id)
      on delete cascade
    SQL
           )
  end

	def down
		execute('alter table code_dates drop constraint fk_code_date_stock_key')
	end
end
