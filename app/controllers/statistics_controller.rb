class StatisticsController < ApplicationController
  
  # GET /statistics
  def index
    
    @rankOfEntryCount = Tag.order("count_member_id desc").group(:member_id).count(:member_id)
    
  end
end
