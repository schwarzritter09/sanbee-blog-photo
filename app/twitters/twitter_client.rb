require 'twitter'

class TwitterClient
  
  def tweet(article)
    begin
      text = make_tweet(article)
      
      client = get_client
      
      tweet = client.update(text)
      
    rescue => e
      Rails.logger.error "<<twitter.rake::tweet.update ERROR : #{e.message}>>"
    end
  end
  
  def make_tweet(article)
    
      tweet = "ブログ[#{article.title} - #{article.member.name}]から画像をダウンロードしました！"
      routes = Rails.application.routes.url_helpers
      url = routes.url_for(:controller => "photos", :action => "index", :host => SanbeeBlogPhoto::Application.config.tweet_host, :only_path => false)
      
      # URL,アカウント名を含めて140文字をオーバーする場合、本文を削る
      while true do
        if (tweet.length + url.length + 1) > 140 then
          tweet = tweet[0..tweet.length-1].to_s
        else
          break;
        end
      end
      
      tweet + "\n" + url
  end
  
  def get_client
    
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = SanbeeBlogPhoto::Application.config.tweet_consumer_key
      config.consumer_secret = SanbeeBlogPhoto::Application.config.tweet_consumer_secret
      config.access_token = SanbeeBlogPhoto::Application.config.tweet_access_token
      config.access_token_secret =  SanbeeBlogPhoto::Application.config.tweet_access_token_secret
    end
    
    client
  end
end