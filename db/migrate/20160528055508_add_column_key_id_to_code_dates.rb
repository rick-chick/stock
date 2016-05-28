class AddColumnKeyIdToCodeDates < ActiveRecord::Migration
  def up
		execute "alter table code_dates add stock_key_id bigint"
  end

  def down
		execute "alter table code_dates drop stock_key_id"
  end
end
