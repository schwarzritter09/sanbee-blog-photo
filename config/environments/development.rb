Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  
  config.ap_title = "3Bjrブログ画像まとめ"
  
  config.img_path_root = "/var/img/"
  
  config.article_link_css = "#main h2 a"
  config.date_css = ".skin-entryPubdate time"
  config.title_css = ".skin-entryTitle a"
  config.theme_css = ".skin-entryThemes dd a"
  config.image_link_css = "a.detailOn"
  config.image_css = "#imgEncircle img"
  
  config.entrylist_url = "http://ameblo.jp/3bjr/entrylist.html"
  
  config.entrylist_number_url_prefix = "http://ameblo.jp/3bjr/entrylist-"
  config.entrylist_number_url_suffix = ".html"
  
  config.lineblog_ua = "Mozilla/5.0 (Linux; Android 6.0.1; SOV34 Build/39.0.C.0.282) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.81 Mobile Safari/537.36"
  config.lineblog_article_link_css = ".article-list a"
  config.lineblog_date_css = "li.article-datetime time"
  config.lineblog_title_css = ".article-title"
  config.lineblog_image_link_css = "div.article-body div a"
  config.lineblog_image_css = "img"
  
  config.tweet_host = "localhost"
  config.tweet_consumer_key = "zYrvDAVNm0QRfdGkOVXOh55MX"
  config.tweet_consumer_secret = "Efttcdt6pdLeIw1X6hnbX5LrgVRDbc4y0SodePYeBE01DmLjw2"
  config.tweet_access_token = "209984728-0heNNNwAcN4t8YrrNG5JoYsK4ujYpE7TIKDuZmCQ"
  config.tweet_access_token_secret = "zHD8sx6TT5MyxHHEYT1axnRYDABhTC02GsS7FhofZyAHG"
end
