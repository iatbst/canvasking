module PricingHelper

  def read_size_price_table
    YAML.load(File.read(Rails.root.join('business','pricing.yml')))
  end
end
