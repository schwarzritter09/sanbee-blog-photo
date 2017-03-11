class Statistics2Controller < ApplicationController
  
  # GET /statistics2
  def index
                
    @members = Member.where.not(unit_id: 7)
    @ranks = Hash.new
    @counts = Hash.new
    
    @members.each do |m|
       
      @counts[m.id] = Hash.new
      @members.each do |m2|
        if(m.id < m2.id)
          photo_search = Hash.new
          photo_search[:member_id] = [m.id, m2.id]
          @counts[m.id][m2.id] = Photo.and_only(photo_search).count
        end
      end 
    end
  end
end
