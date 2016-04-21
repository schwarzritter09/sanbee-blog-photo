class Photo < ActiveRecord::Base
  has_many :tags, -> {where("count > ?", 0)}
  has_many :members, :through => :tags
  belongs_to :create_member, :class_name => "Member", :foreign_key => "create_member_id"

  scope :has_tag_member_id, -> member_ids { joins(:tags).where("tags.member_id in (?)", member_ids)}
  
  scope :update_get, -> datetime { where('created_at > ?', datetime)}
  
  def self.search(photo_search)

    photos = Photo.all

    if photo_search
      photos = photos.where(create_member_id: photo_search[:create_member_id]) if photo_search[:create_member_id].present?
      photos = photos.has_tag_member_id(article_search[:member_id]) if photo_search[:member_id].present?
    end

    photos.order('id DESC')

  end
end
