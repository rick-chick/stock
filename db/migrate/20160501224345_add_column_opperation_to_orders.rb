class AddColumnOpperationToOrders < ActiveRecord::Migration
  def up
		execute "alter table orders add opperation varchar(1)"
  end

  def down
		execute "alter table orders drop opperation"
  end
end
