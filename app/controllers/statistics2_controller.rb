class Statistics2Controller < ApplicationController
  
  # GET /statistics2
  def index
                
    @members = Member.where.not(unit_id: 7)
    @ranks = Hash.new
    @counts = Hash.new

    target_photo_ids = Tag.select(:photo_id).
                           where("count > ?", 0).
                           group(:photo_id).
                           having("count(photo_id) = ?", 2)
    
    master_photo_ids = Photo.where(id: target_photo_ids.uniq.pluck(:photo_id)).pluck(:id)

    @members.each do |m|
       
      @counts[m.id] = Hash.new
      @members.each do |m2|
        if(m.id < m2.id)
          photo_ids = master_photo_ids & Tag.where(member_id: m.id).where("count > 0").pluck(:photo_id) 
          photo_ids = photo_ids & Tag.where(member_id: m2.id).where("count > 0").pluck(:photo_id) 

          @counts[m.id][m2.id] = photo_ids.count
        end
      end 
    end
  end
end
