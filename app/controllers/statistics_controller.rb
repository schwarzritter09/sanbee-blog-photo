class StatisticsController < ApplicationController
  
  # GET /statistics
  def index
    
    @allCount = Photo.all.count
    taged_ids = Photo.joins(:tags).uniq.pluck(:id)
    nottaged_ids = Photo.where.not(id: taged_ids)
    @tagedCount = taged_ids.count
    @notTagedCount = nottaged_ids.count
    @rankOfEntryCount = Tag.order("count_member_id desc").group(:member_id).count(:member_id)
    
  end
end
