require 'bundler'
require 'sinatra'
require 'mongoid'
require 'sinatra/reloader' if :development
require 'debugger' if :development
require "rack/oauth2/sinatra"
require "rack/oauth2/server/admin"


class Hitchhicker_config < Sinatra::Base
  register Rack::OAuth2::Sinatra

configure :development do
  oauth.database = Mongo::Connection.new["API_DEV"]
  Bundler.setup(:default, :assets, :development)
  set :environment, :development
  enable :sessions, :logging, :static, :inline_templates, :method_override, :dump_errors, :run
  Mongoid.load!(File.join(File.dirname(__FILE__),'mongoid.yaml'), :development)
end
    
configure :test do
  oauth.database = Mongo::Connection.new["API_TEST"]
  Bundler.setup(:default, :assets, :test)
  set :environment, :test
  enable :sessions, :logging, :static, :inline_templates, :method_override, :dump_errors, :run
  Mongoid.load!(File.join(File.dirname(__FILE__),'mongoid.yaml'), :test)
end
end