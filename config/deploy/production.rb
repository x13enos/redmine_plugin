# -*- encoding : utf-8 -*-
set :deploy_to, "/home/redmine/application"
set :user, "redmine"
set :application, "redmine"
set :rvm_type, :user

set :rails_env, "production"

set :use_sudo, false
set :unicorn_conf, "#{deploy_to}/current/config/unicorn.rb"
set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"

set :domain, "151.236.217.245"
role :web, domain
role :app, domain
role :db,  domain, :primary => true

set :loops_pid, "#{shared_path}/pids/loops.pid"
set :loops_pid_exists, "[ -f #{loops_pid} ] && [ -e /proc/$(cat #{loops_pid}) ]"

set :branch, "master"
server '151.236.217.245', :web, :app, :db, :primary => true
set :keep_releases, 3
set :bundle_without, [:test, :development] #

set :requires_websrv?, true

after :'deploy:finalize_update', :'deploy:run_after_finalize_update'
                                           #before :'deploy:update', :'solr:stop'
                                           #after :'deploy:finalize_update', :'solr:start'

namespace :deploy do
  desc "Copy production database configuration"
  task :run_after_finalize_update, :roles => [:app, :db, :web] do
    # run "rvm rvmrc trust #{release_path}"
    #copy config
    run "cp #{release_path}/config/deploy/production/database.yml #{release_path}/config/database.yml"
    run "cp #{release_path}/config/deploy/production/unicorn.rb #{release_path}/config/unicorn.rb"
    #run "cp #{release_path}/config/deploy/demo/app_config.yml #{release_path}/config/app_config.yml"
    #run "cp #{release_path}/config/deploy/demo/loops.yml #{release_path}/config/loops.yml"
    run "cp #{release_path}/config/deploy/production/.rvmrc #{release_path}/.rvmrc"
    #run "cp #{release_path}/config/deploy/production/sunspot.yml #{release_path}/config/sunspot.yml"
    #run "cp #{release_path}/config/deploy/production/schedule.rb #{release_path}/config/schedule.rb"
    #run "cp #{release_path}/config/deploy/production/app_config.yml #{release_path}/config/app_config.yml"
  end

  desc "Setup shared directory."
  task :setup_shared do
    #run "mkdir #{shared_path}/config"
    #put File.read("config/deploy/#{stage_name}/loops.yml"), "#{shared_path}/config/loops.yml"
    put File.read("config/deploy/ctls/djctl"), "#{shared_path}/djctl"
    put File.read("config/deploy/ctls/unicornctl"), "#{shared_path}/unicornctl"
    put File.read("config/deploy/ctls/loopsctl"), "#{shared_path}/loopsctl"
    put File.read("config/deploy/ctls/solrctl"), "#{shared_path}/solrctl"
    puts "Now edit the config files in #{shared_path}."
  end
end
