namespace :scrape do
  desc "Scraping Ameblo"
  
  task :entrylist => :environment do
    host = SanbeeBlogPhoto::Application.config.entrylist_1_host
    url = SanbeeBlogPhoto::Application.config.entrylist_1_url
    save_dir = SanbeeBlogPhoto::Application.config.img_path_root
    force_mode = false
    
    s = ScrapeAmeblo.new
    s.scrape(host, url, save_dir, force_mode, true)
    
    host_hachi = SanbeeBlogPhoto::Application.config.entrylist_2_host
    url_hachi = SanbeeBlogPhoto::Application.config.entrylist_2_url
    
    s_hachi = ScrapeAmeblo.new
    s_hachi.scrape(host_hachi, url_hachi, save_dir, force_mode, true)
    
    lineblog = SanbeeBlogPhoto::Application.config.lineblog_entrylist_1_url
    sl = ScrapeLineblog.new
    sl.scrape(lineblog, save_dir, force_mode, true)

    lineblog_hachi = SanbeeBlogPhoto::Application.config.lineblog_entrylist_2_url
    sl_hachi = ScrapeLineblog.new
    sl_hachi.scrape(lineblog_hachi, save_dir, force_mode, true)
  end
  
  task :otherentry, ['number'] => :environment do |task, args|
    url = SanbeeBlogPhoto::Application.config.entrylist_1_number_url_prefix + args[:number] + SanbeeBlogPhoto::Application.config.entrylist_1_number_url_suffix
    save_dir = SanbeeBlogPhoto::Application.config.img_path_root
    force_mode = false
    
    s = ScrapeAmeblo.new
    s.scrape(url, save_dir, force_mode, true)
  end
  
  task :otherentry_hachi, ['number'] => :environment do |task, args|
    url = SanbeeBlogPhoto::Application.config.entrylist_2_number_url_prefix + args[:number] + SanbeeBlogPhoto::Application.config.entrylist_2_number_url_suffix
    save_dir = SanbeeBlogPhoto::Application.config.img_path_root
    force_mode = false
    
    s = ScrapeAmeblo.new
    s.scrape(url, save_dir, force_mode, true)
  end
  
  task :other, ['url'] => :environment do |task, args|
    url = args[:url]
    save_dir = SanbeeBlogPhoto::Application.config.img_path_root
    force_mode = false
    
    s = ScrapeAmeblo.new
    s.scrape(url, save_dir, force_mode, true)
  end
  
  task :article => :environment do
    
    save_dir = SanbeeBlogPhoto::Application.config.img_path_root
    
    as = Article.where("title is null")
    as.each do |a|
      
      begin
        p "do get [#{a.url}]"
        sa = ScrapeAmeblo.new
        sa.scrapeArticle(a.url, save_dir, true, true)
      rescue => e
        
        p "<<ameblo scrape [#{a.url}] ERROR : #{e.message}>>"
        Rails.logger.error "<<ameblo scrape [#{a.url}] ERROR : #{e.message}>>"
      
        next
      end
    end
  end
end
