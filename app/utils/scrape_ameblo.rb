require 'nokogiri'
require 'capybara'
require 'capybara/poltergeist'
require 'open-uri'

class ScrapeAmeblo

  def scrapeImage(articleId, publishDate, imagepageUrl, downloadPath, isForce)
               
    # 画像ページからオリジナルサイズ画像を取得
    # 画像が取得済みの場合スキップ
    downloadedImage = Photo.where(:url => imagepageUrl).first
    if isForce || downloadedImage.nil?
              
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
       if downloadedImage.nil?
        photo = Photo.create :path=>fileName, :create_member_id=>1, :url=>imagepageUrl, :created_at=>publishDate, :article_id=>articleId
      else
        # 登録済みの場合には、作成日付を更新する
        downloadedImage.created_at = publishDate
        downloadedImage.article_id = articleId
        downloadedImage.save
      end
    end
  end
  

  def scrapeArticle(articleUrl, downloadPath, isForce)
    
    # 該当記事が取得済みの場合スキップ
    downloadedArticle = Article.where(:url => articleUrl).first
    if isForce || downloadedArticle.nil?
        
      # 記事をJavaScript動作込で取得
      articleSession = Capybara::Session.new(:poltergeist)
      articleSession.driver.headers = { 'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X)" } 
      articleSession.visit articleUrl
    
      article = Nokogiri::HTML.parse(articleSession.html)
    
      # セッションを終了
      articleSession.driver.quit
      articleSession.clear
      
      # 投稿日付を取得
      publishDate = article.css(".skin-entryPubdate time").first.content
      p publishDate
          
      # テーマ(投稿メンバー)を取得
      theme = article.css(".skin-entryThemes dd a").first.content
      p theme
      
      # タイトルを取得
      title = article.css(".skin-entryTitle a").first.content
      p title
     
      # 記事をDBに登録
      if downloadedArticle.nil?
        article = Article.create :url=>articleUrl, :created_at=>publishDate
      end
          
      # 画像ページリンク一覧を取得
      imagepageLinks = article.css('a.detailOn')
      imagepageLinks.each do |imagepageLink|
        imagepageUrl = imagepageLink.attribute('href').value
        p imagepageUrl
        
        if downloadedArticle.nil?
          articleId = article.id
        else
          articleId = downloadedArticle.id
        end
        scrapeImage(articleId, publishDate, imagepageUrl, downloadPath, isForce)
      end
      
      # 未完検知のため、titleなどの設定は画像ダウンロードが終わったあとに行う
      if downloadedArticle.nil?
        article.title = title
        article.publish_member = theme
        article.created_at = publishDate
        article.save
      else
        # 登録済みの場合には作成日付を更新する
        downloadedArticle.title = title
        downloadedArticle.publish_member = theme
        downloadedArticle.created_at = publishDate
        downloadedArticle.save
      end
    end
  end

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
        scrapeArticle(articleUrl, downloadPath, isForce)
      end
    
    rescue => e
      Rails.logger.error "<<ameblo scrape [#{url}] ERROR : #{e.message}>>"
    end
  end
end
