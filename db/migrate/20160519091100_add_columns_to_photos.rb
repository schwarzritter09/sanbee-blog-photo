class AddColumnsToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :article_id, :integer
  end
end
