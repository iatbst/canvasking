require 'yaml'


# Somatic yml init
somatic_config_file = File.join(Rails.root, 'config', 'somatic.yml')
if File.exists?(somatic_config_file)
  somatic_config = YAML.load_file(somatic_config_file)
  Rails.configuration.somatic = somatic_config
end