require 'bundler'
require 'sinatra'
require 'mongoid'
require 'sinatra/reloader' if ENV['RACK_ENV'] == 'development'
require 'debugger' if ENV['RACK_ENV'] == 'development'
require "rack/oauth2/sinatra"
require "rack/oauth2/server/admin"


class Hitchhicker_config < Sinatra::Base
  register Rack::OAuth2::Sinatra

  configure :development do
    oauth.database = Mongo::MongoClient.new["API_TEST"]
     oauth.param_authentication = true
    
    Bundler.setup(:default, :assets, :development)
    set :environment, :development
    enable :sessions, :logging, :static, :inline_templates, :method_override, :dump_errors, :run
    Mongoid.load!(File.join(File.dirname(__FILE__),'mongoid.yaml'), :development)
  end
      
  configure :test do
    
    oauth.database = Mongo::MongoClient.new["API_TEST"]
    oauth.param_authentication = true
    
    #oauth.authenticator = lambda do |id, client_secret|
    #  user = Rack::OAuth2::Server::Client.find(id)
    #  user.id if user.client_secret =client_secret
    #end
    
    Bundler.setup(:default, :assets, :test)
    set :environment, :test
    enable :sessions, :logging, :static, :inline_templates, :method_override, :dump_errors, :run
    Mongoid.load!(File.join(File.dirname(__FILE__),'mongoid.yaml'), :test)
  end

  configure :production do
    
    # oauth.database = Mongo::MongoClient.new[ENV['MONGOHQ_URL']]
    # oauth.param_authentication = true
    
    #oauth.authenticator = lambda do |id, client_secret|
    #  user = Rack::OAuth2::Server::Client.find(id)
    #  user.id if user.client_secret =client_secret
    #end
    
    Bundler.setup(:default, :assets, :production)
    set :environment, :production
    enable :sessions, :logging, :static, :inline_templates, :method_override, :dump_errors, :run
    Mongoid.load!(File.join(File.dirname(__FILE__),'mongoid.yaml'), :production)

    #oauth.database = Mongo::MongoClient.new[ENV['MONGOHQ_URL']]
    oauth.param_authentication = true
    
  end
end