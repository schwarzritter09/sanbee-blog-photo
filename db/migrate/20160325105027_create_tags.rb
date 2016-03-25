class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.integer :photo_id
      t.integer :member_id
      t.integer :count

      t.timestamps null: false
    end
  end
end
