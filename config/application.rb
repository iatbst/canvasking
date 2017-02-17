require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Canvasking
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    
    # No fields_with_errors div added 
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| 
      html_tag
    }
    
  end
  
  ###################
  #  The Constants  #
  ###################
  # Images
  IMAGE_ORIGINAL_SIZE_LIMIT = 3000
  IMAGE_CROP_SIZE = 450
  
  IMAGE_VER_ORI = 3000
  IMAGE_VER_CART = 450
  IMAGE_VER_CROP = 450
  IMAGE_VER_OVERVIEW = 300
  IMAGE_VER_THUMB = 200
  
  IMAGE_TMP_CACHE_TIME = 24 # Cache time to store image in tmp folder: 24 hours now
  
  # Stripe
  STRIPE_PUBLISH_KEY_TEST = 'pk_test_86PXfTHcS3DHW58QnF6kGP5Q'
  STRIPE_SECRET_KEY_TEST = 'sk_test_En5i3qV5z1Rm7JU0z1r3ppoR'
  
  # EMail
  GMAIL_TEST_USER = 'agarienforcement@gmail.com'
  GAMIL_TEST_USER_PW = 'agarienforce'
  
  # Heroku
  # HEROKU_HOST_URL = 'https://radiant-tundra-25592.herokuapp.com/'
  # This will be replaced with real web url
  WEBSITE_URL = 'http://ec2-52-37-1-190.us-west-2.compute.amazonaws.com/'
  
  # Facebook/Instagram
  FACEBOOK_APP_ID = '744629489021986'
  INSTAGRAM_APP_ID = 'adca74ff860d43d18d264082283df380'
  if Rails.env == "development"
    INSTAGRAM_RE_URL = 'http://localhost:3000'
  elsif Rails.env == "production"
    INSTAGRAM_RE_URL = 'http://ec2-52-37-1-190.us-west-2.compute.amazonaws.com'
  end
  
  # Administrators
  ADMINISTRATORS = ['iatbst@gmail.com']
  
  # TaoBao
  TAOBAO_ORDER_DETAIL_URL = 'https://trade.taobao.com/trade/detail/trade_order_detail.htm'
  TAOBAO_SHIPPING_DETAIL_URL = 'https://detail.i56.taobao.com/trace/trace_detail.htm'
  TAOBAO_ORDER_QUERY_INTERVAL = 3600
  ORDER_CLOSED_WAITING_TIME = 3600*24*30 # wait 30 days after customer received product, before marking order status to CLOSED
end
