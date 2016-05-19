class AddColumnsToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :title, :string
    add_column :articles, :publish_member, :string
  end
end
