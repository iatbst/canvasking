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
    
    config.exceptions_app = self.routes
    
    config.autoload_paths += %W(#{config.root}/lib)
  end
  
  ############################################################################
  #  The Constants: All sensative data are stored in application.yml         #
  ############################################################################
  # Images
  IMAGE_ORIGINAL_SIZE_LIMIT = 3000
  IMAGE_CROP_SIZE = 450  
  IMAGE_VER_ORI = 3000
  IMAGE_VER_CART = 450
  IMAGE_VER_CROP = 450
  IMAGE_VER_OVERVIEW = 300
  IMAGE_VER_THUMB = 200
  IMAGE_TMP_CACHE_TIME = 1 # Cache time to store image in tmp folder: 1 hours now
  
  # Facebook/Image uplad
  INSTAGRAM_PHOTO_COUNT = 20
  
  # EMail
  # GMAIL_TEST_USER = 'agarienforcement@gmail.com'
  # GAMIL_TEST_USER_PW = 'agarienforce'
  ADMIN_EMAIL = 'iatbst@gmail.com'
  
  # S3 buckets
  if Rails.env == "development"
    S3_IMAGE_BUCKET = "canvasking-user-upload-images"
    S3_REGION = "us-west-2"
  elsif Rails.env == "production"
    S3_IMAGE_BUCKET = "canvasking-user-upload-images-production"
    S3_REGION = "us-east-1"
  elsif Rails.env == "staging"
    S3_IMAGE_BUCKET = "canvasking-user-upload-images-stage"
    S3_REGION = "us-east-1"
  end
  
  # EC2
  STAGING_PUB_IP = '52.37.1.190'
  PRODUCTION_PUB_IP = '34.210.149.42'
  
  # Administrators
  ADMINISTRATORS = ['iatbst@gmail.com']

  # SHIPPING
  SHIPPING_COUNTRIES = ['United States']
    
  # TaoBao
  TAOBAO_ORDER_DETAIL_URL = 'https://trade.taobao.com/trade/detail/trade_order_detail.htm'
  TAOBAO_SHIPPING_DETAIL_URL = 'https://detail.i56.taobao.com/trace/trace_detail.htm'
  TAOBAO_ORDER_QUERY_INTERVAL = 3600
  ORDER_CLOSED_WAITING_TIME = 60
  #ORDER_CLOSED_WAITING_TIME = 3600*24*30 # wait 30 days after customer received product, before marking order status to CLOSED
  TAOBAO_OEM_1_ID = '1739501216'
  TAOBAO_OEM_2_ID = '142379829'
  # TaoBao Rule: 
  # Suppose length > width
  # length x 3 + width x 2 <= TAOBAO_SHIPPING_LIMIT, otherwise rejected
  TAOBAO_SHIPPING_LIMIT = 330

  # Product Prices
  # - Currency: RMB
  # - Canvas price: https://item.taobao.com/item.htm?spm=a1z10.5-c.w4002-9476290978.51.xWbvhX&id=525855989381
  DOLLAR_RATE = 6.9
  SHIPMENT_FEE = 22
  PROFIT_RATE = 1.5
  MARKETING_RATE = 0.65
  CANVAS_BASE_PRICES = {
      '12x12' => 17.50,
      '12x16' => 23.10,
      '12x24' => 35.00,
      '12x36' => 47.60,
      '16x16' => 30.80,
      '16x20' => 39.20,
      '16x24' => 42.00,
      '16x32' => 52.50,
      '20x20' => 43.40,
      '20x24' => 52.50,
      '20x28' => 56.00,
      '20x32' => 64.40,
      '20x36' => 72.10,
      '20x40' => 87.50,
      '24x24' => 58.10,
      '24x28' => 67.20,
      '24x32' => 77.00,
      '24x36' => 94.50,
      '24x40' => 105.00,
      '28x28' => 78.40,
      '28x36' => 109.90,
      '28x40' => 137.20,
      '32x32' => 112.00,
      '32x40' => 156.80,    
   }
   # - Canvas Options Prices
   CANVAS_ROLL_DISCOUNT = 0.1
   CANVAS_DEPTH_1_5_ADD = 0.1
   CANVAS_FRAME_ADD = 0.75

    
end
