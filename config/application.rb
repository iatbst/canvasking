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
  
  
  # EMail
  # GMAIL_TEST_USER = 'agarienforcement@gmail.com'
  # GAMIL_TEST_USER_PW = 'agarienforce'
  
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
  PRODUCTION_PUB_IP = '35.164.209.22'
  
  # Administrators
  ADMINISTRATORS = ['iatbst@gmail.com']
  
  # TaoBao
  TAOBAO_ORDER_DETAIL_URL = 'https://trade.taobao.com/trade/detail/trade_order_detail.htm'
  TAOBAO_SHIPPING_DETAIL_URL = 'https://detail.i56.taobao.com/trace/trace_detail.htm'
  TAOBAO_ORDER_QUERY_INTERVAL = 3600
  ORDER_CLOSED_WAITING_TIME = 3600*24*30 # wait 30 days after customer received product, before marking order status to CLOSED
end
