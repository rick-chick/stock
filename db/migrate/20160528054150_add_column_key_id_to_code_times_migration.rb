class AddColumnKeyIdToCodeTimesMigration < ActiveRecord::Migration
  def up
		execute "alter table code_times add stock_key_id bigint"
  end

  def down
		execute "alter table code_times drop stock_key_id"
  end
end
