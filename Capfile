require 'rubygems'
require 'capistrano-buildpack'

set :application, "pingo"
set :repository, "git@github.com:peterkeen/pingo.git"
set :scm, :git
set :buildpack_url, "git@git.zrail.net:peter/bugsplat-buildpack-ruby-shared"

set :user, "peter"

set :concurrency, "web=1"

load 'deploy'

role :web, "kodos.zrail.net"
set :base_port, 6600

set :foreman_export_path, "/lib/systemd/system"
set :foreman_export_type, "systemd"  

set :additional_domains, %w(
  po
  po.petekeen.net
  po.pkn.me
)

read_env 'prod'
