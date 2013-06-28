require 'sinatra'
require 'mongoid'
require 'sinatra/reloader' if :development
require 'debugger' if :development

['user'].each do |file|
  require File.join(File.dirname(__FILE__), 'lib', "#{file}.rb")
end

# class Hitchhiker_API < Sinatra::Base
  before do
    content_type 'application/json'
  end

  get '/' do
    'hello world'
  end

  get '/users' do
    User.all.to_json
  end
# end