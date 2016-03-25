class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :path
      t.integer :create_member_id

      t.timestamps null: false
    end
  end
end
