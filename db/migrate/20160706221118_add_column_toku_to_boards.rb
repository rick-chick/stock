class AddColumnTokuToBoards < ActiveRecord::Migration
  def up
		execute "alter table boards add toku boolean"
  end

  def down
		execute "alter table boads drop toku"
  end
end
