require 'sinatra'
require 'mongoid'
require 'sinatra/reloader' if :development
require 'debugger' if :development

['user'].each do |file|
  require File.join(File.dirname(__FILE__), 'lib', "#{file}.rb")
end

before do
  content_type 'application/json'
end

get '/' do
  'hello world'
end

get '/users' do
  User.all.to_json
end

post '/users' do
  halt 400 if request.params.nil?
  user = User.new request.params 

  halt 500 unless user.save

  [201, user.to_json]
end

get '/users/drivers' do
  User.where(hitchhiker: 'false').to_json
end

get '/users/hitchhikers' do
  User.where(hitchhiker: 'true').to_json
end

put '/users/:id' do
  user = User.find_by(_id: params[:id])
  halt 404 if user.nil?

  halt 400 if params.to_json.nil?

  %w(username hitchhiker).each do |key|
    unless params[key].nil? || params[key] == user[key]
      user[key] = params[key]
    end
  end

  halt 500 unless user.save

  [204]
end

delete '/users/:id' do
  user = User.find_by(_id: params[:id])
  halt 404 if user.nil?

  halt 500 unless user.destroy
end

# get '/users/lat=:lat&long=:long' do
#   debugger
#   users = User.where loc: { '$near' => [ params[:lat], params[:long] ], '$maxdistance' => 5 }
#   users
#   debugger

# end

get '/users/lat=:lat&long=:long' do
  debugger
end