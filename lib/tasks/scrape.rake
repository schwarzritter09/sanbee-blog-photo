namespace :scrape do
  desc "Scraping Ameblo"
  
  task :entrylist => :environment do
    url = "http://ameblo.jp/3bjr/entrylist.html"
    save_dir = SanbeeBlogPhoto::Application.config.img_path_root
    force_mode = false
    
    s = ScrapeAmeblo.new
    s.scrape(url, save_dir, force_mode)
  end
  
  task :otherentry, ['number'] => :environment do |task, args|
    url = "http://ameblo.jp/3bjr/entrylist-#{args[:number]}.html"
    save_dir = SanbeeBlogPhoto::Application.config.img_path_root
    force_mode = false
    
    s = ScrapeAmeblo.new
    s.scrape(url, save_dir, force_mode)
  end
  
  task :article => :environment do
    
    save_dir = SanbeeBlogPhoto::Application.config.img_path_root
    
    as = Article.where("title is null")
    as.each do |a|
      
      begin
        p "do get [#{a.url}]"
        sa = ScrapeAmeblo.new
        sa.scrapeArticle(a.url, save_dir, true)
      rescue => e
        
        p "<<ameblo scrape [#{a.url}] ERROR : #{e.message}>>"
        Rails.logger.error "<<ameblo scrape [#{a.url}] ERROR : #{e.message}>>"
      
        next
      end
    end
  end
end
