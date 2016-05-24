class StatisticsController < ApplicationController
  
  # GET /statistics
  def index
    
    @allCount = Photo.all.count
    taged_ids = Photo.joins(:tags).uniq.pluck(:id)
    nottaged_ids = Photo.where.not(id: taged_ids)
    @tagedCount = taged_ids.count
    @notTagedCount = nottaged_ids.count
    
    # 写真全体での統計
    entryCount = Tag.order("count_member_id desc").group(:member_id).count(:member_id)
    solo_photo_ids = Tag.select(:photo_id).group(:photo_id).having("count(photo_id) = 1").pluck(:photo_id)
    soloEntryCount = Tag.where(photo_id: solo_photo_ids).order("count_member_id desc").group(:member_id).count(:member_id)
        
    @members = Member.where.not(id: [27,28])
    @ranks = Hash.new
    @members.each do |m|
      entryCount[m.id] = 0 if entryCount[m.id].nil?
      soloEntryCount[m.id] = 0 if soloEntryCount[m.id].nil?

      # 自身の上げたブログでの統計
      entryCountByOwner = Article.where(member_id: m.id).joins(:photo).count()
      solo_photo_by_owner_ids = Tag.where(member_id: m.id).joins(:article).select(:photo_id).where("articles.member_id = ?", m.id).group(:photo_id).having("count(photo_id) = 1"
).pluck(:photo_id)
      soloEntryCountByOwner = Tag.where(member_id: m.id).where(photo_id: solo_photo_by_owner_ids).order("count_member_id desc").group(:member_id).count(:member_id)

      if entryCount[m.id].present? && soloEntryCount[m.id].present? && entryCount[m.id] != 0 && soloEntryCount[m.id] != 0
        ratio = soloEntryCount[m.id]/entryCount[m.id].to_f*100
        ratio = ratio.round(3)
      else
        ratio = 0
      end
      
      if entryCountByOwner.present? && soloEntryCountByOwner[m.id].present? && entryCountByOwner != 0 && soloEntryCountByOwner[m.id] != 0
        ratioByOwner = soloEntryCountByOwner[m.id]/entryCountByOwner.to_f*100
        ratioByOwner = ratioByOwner.round(3)
      else
        ratioByOwner = 0
      end
      
      @ranks[m.id] = {:count=>entryCount[m.id], :soloCount=>soloEntryCount[m.id], :ratio=>ratio,
                      :countByOwner=>entryCountByOwner, :soloCountByOwner=>soloEntryCountByOwner[m.id], :ratioByOwner=>ratioByOwner}
    end
  end
end
