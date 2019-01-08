namespace :scrape do
  desc "Scraping Ameblo"
  
  task :entrylist => :environment do
    save_dir = SanbeeBlogPhoto::Application.config.img_path_root
    force_mode = false

    s = ScrapeAmeblo.new

    host = SanbeeBlogPhoto::Application.config.entrylist_1_host
    url = SanbeeBlogPhoto::Application.config.entrylist_1_url
    tag = SanbeeBlogPhoto::Application.config.entrylist_1_tag
    s.scrape(host, url, save_dir, force_mode, true, tag)
    
    host = SanbeeBlogPhoto::Application.config.entrylist_2_host
    url = SanbeeBlogPhoto::Application.config.entrylist_2_url
    tag = SanbeeBlogPhoto::Application.config.entrylist_2_tag
    s.scrape(host, url, save_dir, force_mode, true, tag)
    
    sl = ScrapeLineblog.new

    url = SanbeeBlogPhoto::Application.config.lineblog_entrylist_1_url
    tag = SanbeeBlogPhoto::Application.config.lineblog_entrylist_1_tag
    sl.scrape(url, save_dir, force_mode, true, tag)

    url = SanbeeBlogPhoto::Application.config.lineblog_entrylist_2_url
    tag = SanbeeBlogPhoto::Application.config.lineblog_entrylist_2_tag
    sl.scrape(url, save_dir, force_mode, true, tag)

    url = SanbeeBlogPhoto::Application.config.lineblog_entrylist_3_url
    tag = SanbeeBlogPhoto::Application.config.lineblog_entrylist_3_tag
    sl.scrape(url, save_dir, force_mode, true, tag)
  end
  
  task :otherentry, ['number'] => :environment do |task, args|
    url = SanbeeBlogPhoto::Application.config.entrylist_1_number_url_prefix + args[:number] + SanbeeBlogPhoto::Application.config.entrylist_1_number_url_suffix
    save_dir = SanbeeBlogPhoto::Application.config.img_path_root
    force_mode = false
    
    s = ScrapeAmeblo.new
    s.scrape(url, save_dir, force_mode, true)
  end
  
  task :otherentry_hachi, ['number'] => :environment do |task, args|
    host = SanbeeBlogPhoto::Application.config.entrylist_2_host
    url = SanbeeBlogPhoto::Application.config.entrylist_2_number_url_prefix + args[:number] + SanbeeBlogPhoto::Application.config.entrylist_2_number_url_suffix
    save_dir = SanbeeBlogPhoto::Application.config.img_path_root
    force_mode = false
    tag = SanbeeBlogPhoto::Application.config.entrylist_2_tag
    
    s = ScrapeAmeblo.new
    s.scrape(host, url, save_dir, force_mode, true, tag)
  end
  
  task :other, ['url'] => :environment do |task, args|
    url = args[:url]
    save_dir = SanbeeBlogPhoto::Application.config.img_path_root
    force_mode = false
    tag = SanbeeBlogPhoto::Application.config.entrylist_2_tag
    
    s = ScrapeAmeblo.new
    s.scrape(url, save_dir, force_mode, tag, true)
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
