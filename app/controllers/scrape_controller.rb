class ScrapeController < ApplicationController
  
  # GET /scrape/
  # 
  def index
    
    s = ScrapeAmeblo.new
    s.scrape("http://ameblo.jp/3bjr/entrylist.html",SanbeeBlogPhoto::Application.config.img_path_root ,false)
  end
end
