# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server "example.com", user: "deploy", roles: %w{app db web}, my_property: :my_value
# server "example.com", user: "deploy", roles: %w{app web}, other_property: :other_value
# server "db.example.com", user: "deploy", roles: %w{db}

server Canvasking::STAGING_PUB_IP, user: 'deploy', roles: %w{web app db worker s3}

# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}



# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.
set :branch, :development
set :puma_env, :staging
set :rails_env, :staging

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server "example.com",
#   user: "user_name",
#   roles: %w{web app},
#   ssh_options: {
#     user: "user_name", # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: "please use keys"
#   }

desc "Sync S3 from production to staging"
task :sync_staging_s3_with_production do
  on roles(:s3) do
    prod_bucket = "canvasking-user-upload-images-production"
    stage_bucket = "canvasking-user-upload-images-stage"
    aws_sync_cmd = "aws s3 sync s3://#{prod_bucket} s3://#{stage_bucket} --delete --acl public-read"
    execute "#{aws_sync_cmd}"
  end
end
after "deploy:finished", "sync_staging_s3_with_production"

desc "Clone DB from production to staging"
task :sync_staging_db_with_production do
  on roles(:db) do
    # copy sql dump file from prod to staging
    database_backups_path = "/home/deploy/database_backups"
    prod_host = "ec2-52-40-234-37.us-west-2.compute.amazonaws.com"
    sql_file = "canvasking_production_current.sql"
    scp_cmd = "scp deploy@#{prod_host}:#{database_backups_path}/#{sql_file} #{database_backups_path}"
    execute "#{scp_cmd}"
    
    # drop db in staging
    db_name = 'canvasking_staging'
    db_user = 'deploy'
    execute "echo \"SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='canvasking_staging'; DROP DATABASE #{db_name}\; CREATE DATABASE #{db_name}\" | psql -d postgres"
      
    # restore db from dump file
    restore_cmd = "psql -d #{db_name} -f #{database_backups_path}/#{sql_file}"
    execute "#{restore_cmd}"
   end
end
before "deploy:migrate", "sync_staging_db_with_production"