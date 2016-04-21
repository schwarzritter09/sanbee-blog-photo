class AddUnitIdToMembers < ActiveRecord::Migration
  def change
    add_column :members, :unit_id, :int
  end
end
