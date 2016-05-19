class StatisticsController < ApplicationController
  
  # GET /statistics
  def index
    
    @allCount = Photo.all.count
    taged_ids = Photo.joins(:tags).uniq.pluck(:id)
    nottaged_ids = Photo.where.not(id: taged_ids)
    @tagedCount = taged_ids.count
    @notTagedCount = nottaged_ids.count
    
    entryCount = Tag.order("count_member_id desc").group(:member_id).count(:member_id)
    solo_photo_ids = Tag.select(:photo_id).group(:photo_id).having("count(photo_id) = 1").pluck(:photo_id)
    soloEntryCount = Tag.where(photo_id: solo_photo_ids).order("count_member_id desc").group(:member_id).count(:member_id)
    
    @members = Member.where.not(id: [27,28])
    @ranks = Hash.new
    @members.each do |m|
      entryCount[m.id] = 0 if entryCount[m.id].nil?
      soloEntryCount[m.id] = 0 if soloEntryCount[m.id].nil?

      if entryCount[m.id] != 0 && soloEntryCount[m.id] != 0
        ratio = soloEntryCount[m.id]/entryCount[m.id].to_f*100
        ratio = ratio.round(3)
      else
        ratio = 0
      end
      @ranks[m.id] = {:count=>entryCount[m.id], :soloCount=>soloEntryCount[m.id], :ratio=>ratio}
    end
  end
end
