require 'carrierwave/orm/activerecord'


CarrierWave.configure do |config|
  config.storage = :fog
  config.asset_host = "https://s3-us-west-2.amazonaws.com/#{Canvasking::S3_IMAGE_BUCKET}"
  config.fog_credentials = {
    provider:              'AWS',                         # required
    aws_access_key_id:     ENV["aws_access_key_id"],                        # required
    aws_secret_access_key: ENV["aws_secret_access_key"],                        # required
    region:                'us-west-2',                   # optional, defaults to 'us-east-1'
    host:                  nil,                           # optional, defaults to nil
    endpoint:              nil                            # optional, defaults to nil
  }
  config.fog_directory  = Canvasking::S3_IMAGE_BUCKET            # required, bucket name
  config.fog_public     = true                                       # optional, defaults to true
  config.fog_attributes = {} # optional, defaults to {}: Warn, DO NOT SET cache, otherwise cropped image won't updated
end