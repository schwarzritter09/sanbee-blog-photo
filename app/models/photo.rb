class Photo < ActiveRecord::Base
  has_many :tags, -> {where("count > ?", 0)}
  has_many :members, :through => :tags
  belongs_to :create_member, :class_name => "Member", :foreign_key => "create_member_id"
  belongs_to :article

  scope :has_tag_member_id, -> member_ids { joins(:tags).where("tags.member_id in (?)", member_ids).uniq}
  
  scope :update_get, -> datetime { where('created_at > ?', datetime)}
  
  def self.search(photo_search)

    photos = Photo.all

    if photo_search
      if photo_search[:nothingtag].present?
        not_target_ids = Photo.joins(:tags).uniq.pluck(:id)
        photos = Photo.where.not(id: not_target_ids)
        photo_search[:member_id] = nil
      else
        photos = photos.has_tag_member_id(photo_search[:member_id]) if photo_search[:member_id].present?
      end
    end

    photos.order('created_at ASC').order('id DESC')

  end
  
  def previous
    Photo.order('created_at ASC').order('id desc').where('id < ?', id).first
  end

  def next
    Photo.order('created_at ASC').order('id DESC').where('id > ?', id).reverse.first
  end
  
  def previous_notag
    not_target_ids = Photo.joins(:tags).uniq.pluck(:id)
    Photo.order('created_at ASC').order('id DESC').where.not(id: not_target_ids).where('id < ?', id).first
  end

  def next_notag
    not_target_ids = Photo.joins(:tags).uniq.pluck(:id)
    Photo.order('created_at ASC').order('id DESC').where.not(id: not_target_ids).where('id > ?', id).reverse.first
  end
end
