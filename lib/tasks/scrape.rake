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
end
