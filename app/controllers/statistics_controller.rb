class StatisticsController < ApplicationController
  
  # GET /statistics
  def index
    
    @allCount = Photo.all.count
    taged_ids = Photo.joins(:tags).uniq.pluck(:id)
    nottaged_ids = Photo.where.not(id: taged_ids)
    @tagedCount = taged_ids.count
    @notTagedCount = nottaged_ids.count
    @rankOfEntryCount = Tag.order("count_member_id desc").group(:member_id).count(:member_id)
    solo_tag_ids = Tag.group(:photo_id).having("count(photo_id) = 1").pluck(:id)
    @rankOfSoloEntryCount = Tag.where(id: solo_tag_ids).order("count_member_id desc").group(:member_id).count(:member_id)
  end
end
