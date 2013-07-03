require 'sinatra'
require 'mongoid'
require 'sinatra/reloader' if :development
require 'debugger' if :development
require 'rest_client'

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
  #debugger
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

get '/users/long=:long&lat=:lat' do
  # debugger
  users = User.where position: { '$near' => [ params[:lat], params[:long] ], '$maxdistance' => 5 }
  users.to_json
  

end

get '/users/lat=:lat&long=:long' do
  #debugger
  users = User.where position: { '$near' => [ params[:long], params[:lat] ], '$maxdistance' => 5 }
  'hi'
end


#LET'S GET SOME ROUTES
get '/osrm/routes' do
  halt 400 if params.nil?
  %w(from to).each do |key|
    halt 400, "Param [#{key}] is mandatory." if params[key].nil? || params[key].empty?
  end
  data = JSON.parse(RestClient.get("http://router.project-osrm.org/viaroute?loc=#{params[:from]}&loc=#{params[:to]}"))
  halt 404, "Route not found" if data.nil? || data.empty?
  halt 400, "There's a problem with your request: #{data['status_message']}." if data['status'] != 0
  data.to_json
end

get '/osrm/routes-multiple' do
    halt 400 if params.nil? || params[:locations].nil? || params[:locations].size == 0
    locations = params[:locations]

    q_string = []
    locations.values.each {|v| q_string << "loc=#{v}"}

    data = JSON.parse(RestClient.get("http://router.project-osrm.org/viaroute?#{q_string.join('&')}"))
    halt 404, "Route not found" if data.nil? || data.empty?
    halt 400, "There's a problem with your request: #{data['status_message']}." if data['status'] != 0
    data.to_json
end






