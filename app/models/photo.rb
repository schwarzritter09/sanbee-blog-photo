class Photo < ActiveRecord::Base
  has_many :tags, -> {where("count > ?", 0)}
  has_many :members, :through => :tags
  belongs_to :create_member, :class_name => "Member", :foreign_key => "create_member_id"
  belongs_to :article

  scope :has_tag_member_id, -> member_ids { joins(:tags).where("tags.member_id in (?)", member_ids).uniq}
  
  scope :update_get, -> datetime { where('created_at > ?', datetime)}
  
  def self.solo_only(member_id)
    
    # 単独メンバーのONLY検索
    target_photo_ids = Tag.select(:photo_id).
                           where("count > 0").
                           where(photo_id: Tag.where("count > 0").where(member_id: member_id).pluck(:photo_id)).
                           group(:photo_id).
                           having("count(photo_id) = 1")
          
    photos = Photo.where(id: target_photo_ids.uniq.pluck(:photo_id))
  end
  
  def self.and_only(photo_search)
    
    # まずは指定メンバー数のみのタグを持つPhotoのidを検索
    # この時点ではメンバーを絞っていない
    target_photo_ids = Tag.select(:photo_id).
                           where("count > ?", 0).
                           group(:photo_id).
                           having("count(photo_id) = ?", photo_search[:member_id].size)
        
    # 一旦抽出
    photo_ids = Photo.where(id: target_photo_ids.uniq.pluck(:photo_id)).pluck(:id)

          
    # 指定メンバーのタグを持つPhotoを抽出
    photo_search[:member_id].each do |mid|
      photo_ids = photo_ids & Tag.where(member_id: mid).where("count > 0").pluck(:photo_id)
    end
    
    Photo.where(id: photo_ids)
  end
  
  def self.and_in(photo_search)
    # まずは指定メンバー数以上のタグを持つPhotoのidを検索
    # この時点ではメンバーを絞っていない
    target_photo_ids = Tag.select(:photo_id).
                           where("count > ?", 0).
                           group(:photo_id).
                           having("count(photo_id) >= ?", photo_search[:member_id].size)
        
    # 一旦抽出
    photos = Photo.where(id: target_photo_ids.uniq.pluck(:photo_id))
          
    # 指定メンバーのタグを持つPhotoを抽出
    photo_search[:member_id].each do |mid|
      photos = photos.where(id: Tag.where(member_id: mid).where("count > 0").pluck(:photo_id))
    end
          
    photos
  end
  
  def self.or_only(photo_search)
    # solo_onlyの結果とand_onlyの結果のマージ
    ids = Array.new
    
    # 全メンバー分のsolo_onlyの結果から、Photo.idを取得しマージ
    photo_search[:member_id].each do |mid|
      ids.concat(Photo.solo_only(mid).pluck(:id))
    end
    
    # and_onlyの結果から、Photo.idを取得しマージ
    ids.concat(Photo.and_only(photo_search).pluck(:id))
    
    Photo.where(id: ids)
  end
  
  def self.or_in(photo_search)
    photos = Photo.has_tag_member_id(photo_search[:member_id]) if photo_search[:member_id].present?
  end
  
  def self.search(photo_search)

    photos = Photo.all

    if photo_search
      if photo_search[:nothingtag].present?
        not_target_ids = Photo.joins(:tags).uniq.pluck(:id)
        photos = Photo.where.not(id: not_target_ids)
        photo_search[:member_id] = nil
      else
        if photo_search[:only].present? && photo_search[:member_id].size == 1
          # 単独メンバーのONLY検索(単独なのでANDは無視できる)
          photos = Photo.solo_only(photo_search[:member_id])
          
        elsif photo_search[:and].present? && photo_search[:only].present?
          # 複数メンバーのAND, ONLY検索
          photos = Photo.and_only(photo_search)
        elsif photo_search[:and].present? && photo_search[:only].nil?
          # 複数メンバーのAND, IN検索
          photos = Photo.and_in(photo_search)
        elsif photo_search[:and].nil? && photo_search[:only].present?
          # 複数メンバーのOR,ONLY条件
          photos = Photo.or_only(photo_search)
        else
          # OR,IN検索(通常)
          photos = Photo.or_in(photo_search)
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
    not_target_ids = Photo.includes(:tags).where(tags: {id: nil}).uniq.pluck(:id)
    Photo.order('created_at DESC').order('id DESC').where(id: not_target_ids).where('id < ?', id).first
  end

  def next_notag
    not_target_ids = Photo.includes(:tags).where(tags: {id: nil}).uniq.pluck(:id)
    Photo.order('created_at DESC').order('id DESC').where(id: not_target_ids).where('id > ?', id).reverse.first
  end
end
