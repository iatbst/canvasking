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
  # Crop 
  IMAGE_ORIGINAL_SIZE_LIMIT = 3000
  IMAGE_CROP_SIZE = 450
  
  IMAGE_VER_ORI = 3000
  IMAGE_VER_CART = 450
  IMAGE_VER_CROP = 450
  IMAGE_VER_OVERVIEW = 300
  IMAGE_VER_THUMB = 200
  
  # Stripe
  STRIPE_PUBLISH_KEY_TEST = 'pk_test_86PXfTHcS3DHW58QnF6kGP5Q'
  STRIPE_SECRET_KEY_TEST = 'sk_test_En5i3qV5z1Rm7JU0z1r3ppoR'
  
  # EMail
  GMAIL_TEST_USER = 'agarienforcement@gmail.com'
  GAMIL_TEST_USER_PW = 'agarienforce'
  
  # Heroku
  HEROKU_HOST_URL = 'https://arcane-sands-61757.herokuapp.com/'
end
