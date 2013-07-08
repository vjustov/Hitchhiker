require 'sinatra'
require 'mongoid'
require 'sinatra/reloader' if :development
require 'debugger' if :development
require 'rest_client'
require "rack/oauth2/sinatra"
require "rack/oauth2/server/admin"

register Rack::OAuth2::Sinatra

['vehicle','user', 'route'].each do |file|
  require File.join(File.dirname(__FILE__), 'lib', "#{file}.rb")
end

before do
  content_type 'application/json'
  @current_user = Rack::OAuth2::Server::Client.find(oauth.identity) if oauth.authenticated?
end

get "/oauth/authorize" do
  debugger
  if @current_user
    render "/oauth/authorize"  
  else
    redirect "/oauth/login?authorization=#{oauth.authorization}"
  end
end


#post "/oauth/grant" do
#  debugger
#  oauth.grant! "Superman"
#end

#post "/oauth/deny" do
#  oauth.deny!
#end








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
  users = User.where position: { '$near' => [ params[:long], params[:lat] ], '$maxdistance' => 5 }
  users.to_json
end

get '/users/:username/routes' do
  halt 400 if params[:username].nil?
  user = User.where(username: params[:username]).first().routes.to_json
end



post '/users/:username/routes' do
  halt 400 if request.params.nil?
  user = User.where('username' => params[:username]).first
  halt 404 if user.nil?
  
  #debugger
  
  route = Route.new JSON.parse(request.params.to_json)
  user.routes << route
  
  halt 500 unless user.save

  [201, user.to_json]
end


put '/routes/:id' do
  route = Route.find_by(_id: params[:id])
  halt 404 if route.nil?

  halt 400 if params.to_json.nil?

  %w(city country route_link available_sits starting_point end_point).each do |key|
    unless params[key].nil? || params[key] == route[key]
      route[key] = params[key]
    end
  end

  halt 500 unless route.save

  [204]
end


delete '/routes/:id' do
  route = Route.find_by(_id: params[:id])
  halt 404 if route.nil?

  halt 500 unless route.destroy
end


post '/routes/:id/schedule' do
  halt 400 if request.params.nil?
  route = Route.where('_id' => params[:id]).first
  halt 404 if route.nil?
   
  route_schedule = Schedule.new JSON.parse(request.params.to_json)
    
  user_routes = route.user.routes
  
  user_routes.each do |user_route|
    
    unless (user_route.schedule.nil?) then 
      schedule = Route.where(
                            { "$or" =>
                                [ 
                                   { "$and" => 
                                      [
                                        { "schedule.arrival" =>  {"$lte" =>  route_schedule.arrival } }
                                        #{ "schedule.arrival_minute" =>  {"$lte" =>  route_schedule.arrival_minute } }
                                      ]
                                   },
                                   {
                                      "$and" => 
                                      [
                                        { "schedule.departure" =>  {"$gte" =>  route_schedule.departure } }
                                        #{ "schedule.departure_minute" =>  {"$gte" =>  route_schedule.departure_minute } }
                                      ]
                                   }
                                ],
                             "user_id" => user_route.user_id }
                  ) 
                  
      
      halt 403 if !schedule.nil? || schedule.size > 0
    end  
  end
    
  route.schedule = route_schedule
    
  halt 500 unless route.save

  [201, route.to_json]
end

put '/routes/:id/schedule' do
  route = Route.find_by(_id: params[:id])
  halt 404 if route.nil?

  halt 400 if params.to_json.nil?
  schedule = Schedule.new
  %w(departure departure arrival date frecuency).each do |key|
    unless params[key].nil? || params[key] == route[key]
      schedule[key] = params[key]
    end
  end
  
  route.schedule = schedule
  
  halt 500 unless route.save

  [204]
end

delete '/routes/:id/schedule' do
  route = Route.find_by(_id: params[:id])
  halt 404 if route.nil?
    route.schedule = nil
  halt 500 unless route.save
end

put '/routes/:id/checkin' do
   route = Route.find_by(_id: params[:id])
  halt 404 if route.nil?

  halt 400 if params.to_json.nil?
  
  halt 403 if route.passengers.size >= route.available_sits
  route.passengers << params[:user_id]

  halt 500 unless route.save

  [204]
end

post '/routes/:id/stops' do
    route = Route.find_by(_id: params[:id])
    stop = Stop.new
  halt 404 if route.nil?

  halt 400 if params.to_json.nil?
  
   %w(duration position).each do |key|
    unless params[key].nil? || params[key] == route[key]
      stop[key] = params[key]
    end
  end
  route.stops << stop

  halt 500 unless route.save

  [201, route.stops.to_json]
end

put '/routes/:id/stops/:id_stop' do
  route = Route.find_by(_id: params[:id])
  stop = route.stops.find_by(_id: params[:id_stop])
  
  halt 404 if route.nil? || stop.nil?  
  halt 400 if params.to_json.nil?
    
  %w(duration position).each do |key|
    unless params[key].nil? || params[key] == route[key]
      stop[key] = params[key]
    end
  end
  halt 500 unless stop.save
  
  [204]
end


delete '/routes/:id/stops/:id_stop' do
  route = Route.find_by(_id: params[:id])
  stop = route.stops.find_by(_id: params[:id_stop])
  
  halt 404 if route.nil? || stop.nil?  
  halt 400 if params.to_json.nil?
  
  halt 500 unless stop.destroy
  
end

get '/users/lat=:lat&long=:long' do
  #debugger
  users = User.where position: { '$near' => [ params[:long], params[:lat] ], '$maxdistance' => 5 }
  users.to_json
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

