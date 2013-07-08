
require File.join(File.dirname(__FILE__), '..', "app.rb")

require 'json'
require 'rack/test'
require 'sinatra'
require 'debugger'
require "rack/oauth2/sinatra"
require "rack/oauth2/server/admin"

register Rack::OAuth2::Sinatra

Mongoid.load!(File.join(File.dirname(__FILE__), '..','mongoid.yaml'), :test)

Rspec.configure do |config|
  config.color_enabled = true
  config.formatter = :documentation
  config.include Rack::Test::Methods  
end
