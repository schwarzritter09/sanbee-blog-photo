class StatisticsController < ApplicationController
  
  # GET /statistics
  def index
    
    @allCount = Photo.all.count
    taged_ids = Photo.joins(:tags).uniq.pluck(:id)
    nottaged_ids = Photo.where.not(id: taged_ids)
    @tagedCount = taged_ids.count
    @notTagedCount = nottaged_ids.count
            
    @members = Member.where.not(unit_id: 7)
    @ranks = Hash.new
    @counts = Hash.new
    
    @members.each do |m|
      
      # 写真全体での統計
      ## 自身が写っている画像をカウント
      entry = Photo.joins(:tags).where("tags.member_id = ?", m.id).uniq(:id)
      ## 他人が写っている画像をカウント
      otherEntry = Photo.joins(:tags).where(id: entry.pluck(:id)).where.not("tags.member_id = ?", m.id).uniq(:id)
      ## 自身のみ写っている画像のカウント(自身が載っている画像のカウントから、他人が写っているカウントを除外)
      soloEntryCount = entry.count - otherEntry.count
      
      # 自身の上げたブログでの統計
      ## 自身が上げた画像のカウント
      entryByOwner = Photo.joins(:tags, :article).where("articles.member_id = ?", m.id).uniq(:id)
      ## 自身が上げた画像の中で、他人が写っている画像のカウント
      otherEntryByOwner = Photo.joins(:tags, :article).where("articles.member_id = ?", m.id).where.not("tags.member_id = ?", m.id).uniq(:id)
      ## 自身のみ写っている画像のカウント(自身が上げた画像のカウントから、他人が写っているカウントを除外)
      soloEntryByOwnerCount = entryByOwner.count - otherEntryByOwner.count
      
      if entry.count != 0 && soloEntryCount != 0
        ratio = soloEntryCount/entry.count.to_f*100
        ratio = ratio.round(3)
      else
        ratio = 0
      end
      
      if entryByOwner.count != 0 && soloEntryByOwnerCount != 0
        ratioByOwner = soloEntryByOwnerCount/entryByOwner.count.to_f*100
        ratioByOwner = ratioByOwner.round(3)
      else
        ratioByOwner = 0
      end
      
      @ranks[m.id] = {:count=>entry.count, :soloCount=>soloEntryCount, :ratio=>ratio,
                      :countByOwner=>entryByOwner.count, :soloCountByOwner=>soloEntryByOwnerCount, :ratioByOwner=>ratioByOwner}

    end
  end
end
