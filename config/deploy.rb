# -*- encoding : utf-8 -*-
set :stages, %w(production)

#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

set :rvm_path, "$HOME/.rvm"
set :rvm_ruby_string, 'ruby-1.9.3-p362@redmine'

set :normalize_asset_timestamps, false
require "rvm/capistrano"
require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require 'capistrano_colors'


`ssh-add`

load 'deploy/assets'

set :repository, "git@github.com:x13enos/redmine_plugin.git"

set :scm, :git

set :deploy_via, :remote_cache
set :rails_env, "production"
set :copy_exclude, [ '.git' ]

ssh_options[:forward_agent] = true

after "deploy:restart",  "deploy:cleanup"

namespace :deploy do
  desc "Full deploying app"
  task :full do
    deploy.update
    deploy.migrate
    deploy.restart
  end

  desc "Restart app"
  task :restart do
    unicorn.restart
  end

  desc "Start app"
  task :start do
    unicorn.read
  end

  desc "Stop app"
  task :stop do
    unicorn.stop
  end
end

namespace :unicorn do
  desc "Restart unicorn"
  task :restart do
    if requires_websrv?
      run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D; fi"
    end
  end
  desc "Start unicorn"
  task :start do
    if requires_websrv?
      run "cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D"
    end
  end
  desc "Stop unicorn"
  task :stop do
    if requires_websrv?
      run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
    end
  end
end

namespace :logs do
  desc "Showing 'rails_env' log"
  task(:tail) {stream "tail -f #{shared_path}/log/#{rails_env}.log"}

  namespace(:unicorn) do
    desc "Showing unicorn log"
    task(:tail) {stream "tail -f #{shared_path}/log/unicorn.log"}
  end
end

