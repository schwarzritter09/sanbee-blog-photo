require 'nokogiri'
require 'capybara'
require 'capybara/poltergeist'
require 'open-uri'

class ScrapeAmeblo
    
  def scrape(url, downloadPath, isForce)
    begin
      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :time_out => 1000})
      end
      Capybara.default_selector = :css
      
      # JavaScript動作込でentrylistを取得
      entrylistSession = Capybara::Session.new(:poltergeist)
      entrylistSession.driver.headers = { 'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X)" } 
      entrylistSession.visit url
      
      entrylist = Nokogiri::HTML.parse(entrylistSession.html)
      
      # セッションを終了
      entrylistSession.driver.quit
            
      # 記事のリンク一覧を取得
      articleLinks = entrylist.css('#main h2 a')
      
      articleLinks.each do |articleLink|
        articleUrl = articleLink.attribute('href').value
        p articleUrl
        
        # 該当記事が取得済みの場合スキップ
        downloadedArticle = Article.where(:url => articleUrl)
        if isForce || downloadedArticle.empty?
        
          # 記事をJavaScript動作込で取得
          articleSession = Capybara::Session.new(:poltergeist)
          articleSession.driver.headers = { 'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X)" } 
          articleSession.visit articleUrl
        
          article = Nokogiri::HTML.parse(articleSession.html)
        
          # セッションを終了
          articleSession.driver.quit
      
          # 画像ページリンク一覧を取得
          imagepageLinks = article.css('a.detailOn')
          imagepageLinks.each do |imagepageLink|
            imagepageUrl = imagepageLink.attribute('href').value
            p imagepageUrl
                    
            # 画像ページからオリジナルサイズ画像を取得
            # 画像が取得済みの場合スキップ
            downloadedImage = Photo.where(:url => imagepageUrl)
            if isForce || downloadedImage.empty?
                  
              # 画像ページをJavaScript動作込で取得
              imagepageSession = Capybara::Session.new(:poltergeist)
              imagepageSession.driver.headers = { 'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X)" } 
              imagepageSession.visit imagepageUrl
  
              imagepage = Nokogiri::HTML.parse(imagepageSession.html)
            
              # セッションを終了
              imagepageSession.driver.quit
        
              # 画像リンクを取得
              imageTag = imagepage.css('#imgEncircle img')
                      
              imageUrl = imageTag.attribute('src').value
          
              p imageUrl
          
              fileName = File.basename(imageUrl)
              filePath = downloadPath + "/" + fileName
          
              open(filePath, 'wb') do |output|
                open(imageUrl) do |data|
                  output.write(data.read)
                end
              end
          
              # 画像をDBへ登録
              if downloadedImage.empty?
                photo = Photo.create :path=>fileName, :create_member_id=>1, :url=>imagepageUrl
              end
            end
          end
          
          # 記事をDBに登録
          if downloadedArticle.empty?
            article = Article.create :url=>articleUrl
          end
        end
      end
    
    rescue => e
      Rails.logger.error "<<ameblo scrape [#{url}] ERROR : #{e.message}>>"
    end
  end
end
