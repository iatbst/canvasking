require File.expand_path('../../application.rb', __FILE__)

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server "example.com", user: "deploy", roles: %w{app db web}, my_property: :my_value
# server "example.com", user: "deploy", roles: %w{app web}, other_property: :other_value
# server "db.example.com", user: "deploy", roles: %w{db}

server Canvasking::PRODUCTION_PUB_IP, user: 'deploy', roles: %w{web app db worker}

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
set :branch, :master
set :puma_env, :production
set :rails_env, :production

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

desc "Backup production db before deployment"
task :backup_production_db do
  on roles(:db) do
    # store latest db in backups folder
    database_backups_path = "/home/deploy/database_backups"
    dbname = "canvasking_production"
    timestamp = Time.now.to_s.split(' ')[0..1].join('-').split(':').join('-')
    current_file = "canvasking_production_current.sql"
    version_file = "canvasking_production_#{timestamp}.sql"
    dump_cmd = "pg_dump #{dbname} > #{database_backups_path}/versions/#{version_file}"
    ln_cmd = "ln -fs #{database_backups_path}/versions/#{version_file} #{database_backups_path}/#{current_file}"
    execute "#{dump_cmd};#{ln_cmd}" 
   end
end
before "deploy:migrate", "backup_production_db"