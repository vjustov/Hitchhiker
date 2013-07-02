require 'sinatra'
require 'mongoid'
require 'sinatra/reloader' if :development
require 'debugger' if :development

['vehicle','user', 'route'].each do |file|
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

# get '/users/lat=:lat&long=:long' do
#   debugger
#   users = User.where loc: { '$near' => [ params[:lat], params[:long] ], '$maxdistance' => 5 }
#   users
#   debugger

# end

get '/users/lat=:lat&long=:long' do
  #debugger
  users = User.where position: { '$near' => [ params[:long], params[:lat] ], '$maxdistance' => 5 }
  'hi'
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

  %w(city country routeLink avaliableSits startingPoint endPoint).each do |key|
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
                                        { "schedule.arrivalHour" =>  {"$lte" =>  route_schedule.arrivalHour } }, 
                                        { "schedule.arrivalMinute" =>  {"$lte" =>  route_schedule.arrivalMinute } }
                                      ]
                                   },
                                   {
                                      "$and" => 
                                      [
                                        { "schedule.departureHour" =>  {"$gte" =>  route_schedule.departureHour } }, 
                                        { "schedule.departureMinute" =>  {"$gte" =>  route_schedule.departureMinute } }
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
  %w(departureHour departureMinute arrivalHour arrivalMinute date frecuency).each do |key|
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
  
  halt 403 if route.passengers.size >= route.avaliableSits
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