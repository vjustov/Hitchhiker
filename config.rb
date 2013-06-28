require 'bundler'
require 'sinatra'
require 'mongoid'
require 'sinatra/reloader' if :development
require 'debugger' if :development

['user'].each do |file|
  require File.join(File.dirname(__FILE__), 'lib', "#{file}.rb")
end

class Hitchhicker_config < Sinatra::Base

configure :development do
  Bundler.setup(:default, :assets, :development)
  set :environment, :development
  enable :sessions, :logging, :static, :inline_templates, :method_override, :dump_errors, :run
  Mongoid.load!(File.join(File.dirname(__FILE__),'mongoid.yaml'), :development)
end
    
configure :test do
  Bundler.setup(:default, :assets, :test)
  set :environment, :test
  enable :sessions, :logging, :static, :inline_templates, :method_override, :dump_errors, :run
  Mongoid.load!(File.join(File.dirname(__FILE__),'mongoid.yaml'), :test)
end
end