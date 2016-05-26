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
        if photo_search[:only].present? && photo_search[:member_id].size == 1
          
          # 単独メンバーのONLY検索(1人しかいないのでANDは無視できる)
          target_photo_ids = Tag.select(:photo_id).
                             where("count > 0").
                             where(photo_id: Tag.where("count > 0").where(member_id: photo_search[:member_id]).pluck(:photo_id)).
                             group(:photo_id).
                             having("count(photo_id) = 1")
          
          photos = photos.where(id: target_photo_ids.uniq.pluck(:photo_id))
          
        elsif photo_search[:and].present? || photo_search[:only].present?
          
          if photo_search[:only].present?
            # 複数メンバーのAND, ONLY検索
            
            # まずは指定メンバー数のみのタグを持つPhotoのidを検索
            # この時点ではメンバーを絞っていない
            target_photo_ids = Tag.select(:photo_id).
                                   where("count > ?", 0).
                                   group(:photo_id).
                                   having("count(photo_id) = ?", photo_search[:member_id].size)
          
            # 一旦抽出
            photos = photos.where(id: target_photo_ids.uniq.pluck(:photo_id))
            
            # 指定メンバーのタグを持つPhotoを抽出
            photo_search[:member_id].each do |mid|
              photos = photos.where(id: Tag.where(member_id: mid).pluck(:photo_id))
            end
          else
            # 複数メンバーのAND, IN検索
            # まずは指定メンバー数以上のタグを持つPhotoのidを検索
            # この時点ではメンバーを絞っていない
            target_photo_ids = Tag.select(:photo_id).
                                   where("count > ?", 0).
                                   group(:photo_id).
                                   having("count(photo_id) >= ?", photo_search[:member_id].size)
          
            # 一旦抽出
            photos = photos.where(id: target_photo_ids.uniq.pluck(:photo_id))
            
            # 指定メンバーのタグを持つPhotoを抽出
            photo_search[:member_id].each do |mid|
              photos = photos.where(id: Tag.where(member_id: mid).pluck(:photo_id))
            end
          end
        else
          photos = photos.has_tag_member_id(photo_search[:member_id]) if photo_search[:member_id].present?
        end
      end
    end

    photos.order('created_at DESC').order('id DESC')

  end
  
  def previous
    Photo.order('created_at DESC').order('id desc').where('id < ?', id).first
  end

  def next
    Photo.order('created_at DESC').order('id DESC').where('id > ?', id).reverse.first
  end
  
  def previous_notag
    not_target_ids = Photo.joins(:tags).uniq.pluck(:id)
    Photo.order('created_at DESC').order('id DESC').where.not(id: not_target_ids).where('id < ?', id).first
  end

  def next_notag
    not_target_ids = Photo.joins(:tags).uniq.pluck(:id)
    Photo.order('created_at DESC').order('id DESC').where.not(id: not_target_ids).where('id > ?', id).reverse.first
  end
end
