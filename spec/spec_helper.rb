require File.join(File.dirname(__FILE__), '..', "app.rb")

require 'json'
require 'rack/test'
require 'sinatra'
require 'debugger'

Mongoid.load!(File.join(File.dirname(__FILE__), '..','mongoid.yaml'), :test)

Rspec.configure do |config|
  config.color_enabled = true
  config.formatter = :documentation
  config.include Rack::Test::Methods  
end