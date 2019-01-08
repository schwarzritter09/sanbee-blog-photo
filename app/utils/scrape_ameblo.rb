require 'nokogiri'
require 'capybara'
require 'capybara/poltergeist'
require 'open-uri'

class ScrapeAmeblo

  def scrapeImage(articleId, publishDate, imagepageUrl, downloadPath, isForce)
    begin         
      p "do get scrapeImage [imagepageUrl]"
      # 画像ページからオリジナルサイズ画像を取得
      # 画像が取得済みの場合スキップ
      savedImage = Photo.where(:url => imagepageUrl).first
      if isForce || savedImage.nil?
                
        # 画像ページをJavaScript動作込で取得
        imagepageSession = Capybara::Session.new(:selenium)
        imagepageSession.visit imagepageUrl
        imagepage = Nokogiri::HTML.parse(imagepageSession.html)
              
        # セッションを終了
        imagepageSession.driver.quit
          
        # 画像リンクを取得
        imageTag = imagepage.css(SanbeeBlogPhoto::Application.config.image_css)
                        
        imageUrl = imageTag.attribute('src').value
        if imageUrl.start_with?("//")
          imageUrl = "http:" + imageUrl
        end
        p imageUrl
            
        fileName = File.basename(imageUrl)
        filePath = downloadPath + "/" + fileName
        
        open(filePath, 'wb') do |output|
          open(imageUrl) do |data|
            output.write(data.read)
          end
        end
            
        # 画像をDBへ登録
        if savedImage.nil?
          savedImage = Photo.create :path=>fileName, :create_member_id=>1, :url=>imagepageUrl, :created_at=>publishDate, :article_id=>articleId
        else
          # 登録済みの場合には、作成日付を更新する
          savedImage.created_at = publishDate
          savedImage.article_id = articleId
          savedImage.save
        end
      end
    
    rescue => e
      p "<<ameblo scrape image [#{imagepageUrl}] ERROR : #{e.message}>>"
      Rails.logger.error "<<ameblo scrape image [#{imagepageUrl}] ERROR : #{e.message}>>"
    end
  end
  

  def scrapeArticle(articleUrl, downloadPath, isForce, isTweet, tag)
    
    begin
      p "do get scrapeArticle [#{articleUrl}]"
      
      # 該当記事が取得済みの場合スキップ
      savedArticle = Article.where(:url => articleUrl).first
      if isForce || savedArticle.nil?
          
        # 記事をJavaScript動作込で取得
        articleSession = Capybara::Session.new(:selenium)
        articleSession.visit articleUrl
      
        article = Nokogiri::HTML.parse(articleSession.html)
      
        # セッションを終了
        articleSession.driver.quit
        
        # 投稿日付を取得
        publishDate = article.css(SanbeeBlogPhoto::Application.config.date_css).first.content
        p publishDate
            
        # テーマ(投稿メンバー)を取得
        theme = article.css(SanbeeBlogPhoto::Application.config.theme_css).first.content.gsub(" ", "").gsub("　","")
        p theme
        
        # タイトルを取得
        title = article.css(SanbeeBlogPhoto::Application.config.title_css).first.content
        p title
       
        # 記事をDBに登録
        if savedArticle.nil?
          savedArticle = Article.create :url=>articleUrl, :created_at=>publishDate
        end
            
        # 画像ページリンク一覧を取得
        imagepageLinks = article.css(SanbeeBlogPhoto::Application.config.image_link_css)
        imagepageLinks.each do |imagepageLink|
          imagepageUrl = imagepageLink.attribute('href').value
          if imagepageUrl.start_with?("//")
            imagepageUrl = "http:" + imagepageUrl
          end
          p imagepageUrl
          
          scrapeImage(savedArticle.id, publishDate, imagepageUrl, downloadPath, isForce)
        end
        
        # 未完検知のため、titleなどの設定は画像ダウンロードが終わったあとに行う
        m = Member.find_by_name(theme)
        savedArticle.title = title
        savedArticle.theme = theme
        savedArticle.member_id = m.id if m.present?
        savedArticle.created_at = publishDate
        savedArticle.save
        
        if isTweet
          twitterClient = TwitterClient.new
          twitterClient.tweet(savedArticle, tag)
        end
      end
      
    rescue => e
      p "<<ameblo scrape article [#{articleUrl}] ERROR : #{e.message}>>"
      Rails.logger.error "<<ameblo scrape article [#{articleUrl}] ERROR : #{e.message}>>"
    end
  end

  def scrape(host, url, downloadPath, isForce, isTweet, tag)
    begin
      Capybara.register_driver :selenium do |app|
        Capybara::Selenium::Driver.new(app,
                                       browser: :chrome,
                                       desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
                                         chrome_options: {
                                           args: %w(headless disable-gpu window-size=1900,1200 lang=ja no-sandbox disable-dev-shm-usage),
                                         }
                                       )
                                      ) 
      end
      Capybara.default_selector = :css
      Capybara.javascript_driver = :headless_chrome
      
      # JavaScript動作込でentrylistを取得
      entrylistSession = Capybara::Session.new(:selenium)
      entrylistSession.visit url
      
      entrylist = Nokogiri::HTML.parse(entrylistSession.html)
      
      # セッションを終了
      entrylistSession.driver.quit
            
      # 記事のリンク一覧を取得
      articleLinks = entrylist.css(SanbeeBlogPhoto::Application.config.article_link_css)
      
      articleLinks.each do |articleLink|
        articleUrl = articleLink.attribute('href').value
        if articleUrl.start_with?("//")
          articleUrl = "http:" + articleUrl
        end
        if articleUrl.start_with?("/")
          articleUrl = host + articleUrl
        end
        p articleUrl
        scrapeArticle(articleUrl, downloadPath, isForce, isTweet, tag)
      end
    
    rescue => e
      p "<<ameblo scrape [#{url}] ERROR : #{e.message}>>"
      Rails.logger.error "<<ameblo scrape [#{url}] ERROR : #{e.message}>>"
    end
  end
end
