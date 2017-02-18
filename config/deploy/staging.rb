# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server "example.com", user: "deploy", roles: %w{app db web}, my_property: :my_value
# server "example.com", user: "deploy", roles: %w{app web}, other_property: :other_value
# server "db.example.com", user: "deploy", roles: %w{db}

server '52.37.1.190', user: 'deploy', roles: %w{web app db worker}

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


desc "Clone DB from production to staging"
task :sync_staging_db_with_production do
  on roles(:db) do
    # copy sql dump file from prod to staging
    database_backups_path = "/home/deploy/database_backups"
    prod_host = "ec2-52-40-234-37.us-west-2.compute.amazonaws.com"
    sql_file = "canvasking_production_1.sql"
    scp_cmd = "scp deploy@#{prod_host}:#{database_backups_path}/#{sql_file} #{database_backups_path}"
    run "#{scp_cmd}"
    
    # drop db in staging
    dbname = 'canvasking_staging'
    run "psql -U postgres",
        :data => <<-"PSQL"
           REVOKE CONNECT ON DATABASE #{dbname} FROM public;
           ALTER DATABASE #{dbname} CONNECTION LIMIT 0;
           SELECT pg_terminate_backend(pid)
             FROM pg_stat_activity
             WHERE pid <> pg_backend_pid()
             AND datname='#{dbname}';
           DROP DATABASE #{dbname};
        PSQL
     
     # restore db from dump file
     restore_cmd = "psql -d #{dbname} -f #{database_backups_path}/#{sql_file}"
     run "#{restore_cmd}"
   end
end
after "deploy:published", "sync_staging_db_with_production"