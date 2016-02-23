
# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'deploy_me'
set :repo_url, 'git@github.com:JIucT/deploy_test.git'

set :user, 'eugene'
set :deploy_to, "/home/eugene/"
role :app, "#{fetch(:user)}@192.168.11.224"
role :web, "#{fetch(:user)}@192.168.11.224"
role :db,  "#{fetch(:user)}@192.168.11.224", primary: true
set :use_sudo, false


########### RVM ###############
# before 'deploy', 'rvm1:install:gems'
set :rvm_ruby_version, '2.3.0@deployment'

###############################


########### NGINX #############
set :nginx_service_path, "/etc/init.d/nginx"
set :nginx_roles, :web
set :nginx_application_name, "default"
set :app_server_socket, "unix:///#{fetch(:deploy_to)}/shared/tmp/sockets/puma.sock"

##############################


########## PUMA ##############
set :puma_init_active_record, true
set :linked_dirs, %w{tmp/pids tmp/sockets log}
set :puma_threads, [4, 16]
set :puma_workers, 0
set :puma_bind, "unix:///#{fetch(:deploy_to)}/shared/tmp/sockets/puma.sock"
set :puma_pid,  "#{fetch(:deploy_to)}/shared/tmp/pids/puma.pid"


# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      invoke 'puma:restart'
      invoke 'nginx:restart'
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
