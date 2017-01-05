require 'yaml'

aws_config_file = File.join(Rails.root, 'config', 'aws.yml')
if File.exists?(aws_config_file)
  aws_config = YAML.load_file(aws_config_file)
  Rails.configuration.aws = aws_config
end