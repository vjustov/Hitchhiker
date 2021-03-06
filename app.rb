require './config.rb'

register Rack::OAuth2::Sinatra

use OmniAuth::Builder do
  provider :facebook, '204327486390146','8c374e0a7d5fcf83632dd7881c0e90df',  {:client_options => {:ssl => {:verify => false}}} 
end

enable :sessions

before do
  content_type 'application/json'
  @current_user = Rack::OAuth2::Server::Client.find(oauth.identity) if oauth.authenticated?
end

get "/oauth/authorize" do
  if @current_user
    render "/oauth/authorize"  
  else
    redirect "/oauth/login?authorization=#{oauth.authorization}"
  end
end

get "/oauth/login" do
  puts oauth 
  erb :login
end

post "/oauth/grant" do
    oauth.grant!(oauth.authorization)
end

post "/oauth/deny" do
  oauth.deny!
end

oauth_required '/'

get '/hitchhikers' do #WE NEED TO REFACTOR THIS!
  unless params[:username].nil?
    user = Hitchhiker.by_username(params[:username])
    halt 404, 'User not found' if user.nil?
    halt 200, user.to_json
  end
  unless params[:email].nil?
    user = Hitchhiker.by_email(params[:email])
    halt 404, 'User not found' if user.nil?
    halt 200, user.to_json
  end
  Hitchhiker.all.to_json
end

post '/hitchhikers' do
  halt 400 if request.params.nil?
  user = Hitchhiker.new request.params 

  halt 500 unless user.save

  [201, user.to_json]
end

get '/hitchhikers/drivers' do
  Hitchhiker.drivers.to_json
end

get '/hitchhikers/hitchhikers' do
  Hitchhiker.hitchhikers.to_json
end

get '/hitchhikers/:id' do
  unless params[:id].nil?

    user = Hitchhiker.find_by(_id: params[:id])
    halt 404, 'User not found' if user.nil?
    halt 200, user.to_json
  else 
    halt 400
  end
# Hitchhiker.all.to_json
end

put '/hitchhikers/:username' do
  halt 400 if params.to_json.nil?

  user = Hitchhiker.by_username(params[:username]).first()
  halt 404 if user.nil?
  
  %w(name lastname email password image admin hitchhiker vehicles).each do |key|
    unless params[key].nil? || params[key] == user[key]
      user[key] = params[key]
    end
  end

  halt 500 unless user.save

  [204]
end

put '/hitchhikers/:username/vehicles' do
  user = Hitchhiker.by_username(params[:username]).first()
  halt 404 if user.nil?
  halt 400 if params.to_json.nil?
  %w(vehicles).each do |key|
    unless params[key].nil? || params[key] == user[key]
      params[key].each do |v_id|
        vehicle = Vehicle.find(v_id)
        user.vehicles << vehicle unless vehicle.nil?
      end
    end
  end

  halt 500 unless user.save
  [204]
end

delete '/hitchhikers/:username' do
  user = Hitchhiker.by_username(params[:username]).first()
  halt 404 if user.nil?

  halt 500 unless user.destroy
end

get '/hitchhikers/long=:long&lat=:lat' do

  users = Hitchhiker.near(params[:long], params[:lat])
  users.to_json
end

get '/hitchhikers/:username/routes' do
  halt 400 if params[:username].nil?
  user = Hitchhiker.by_username(params[:username]).first().routes.to_json
end

post '/hitchhikers/:username/routes' do
  halt 400 if request.params.nil?
  user = Hitchhiker.by_username(params[:username]).first
  halt 404 if user.nil?
  
  #debugger
  
  route = Route.new JSON.parse(request.params.to_json)
  user.routes << route
  
  halt 500 unless user.save

  [201, user.to_json]
end

get '/routes' do
  Route.active_routes.to_json
end

get '/routes/schedule' do
  (Schedule.new).to_json
end

get'/routes/new' do
  Route.new
end

get '/routes/:id' do
  halt 400 if request.params.nil?
  route = Route.find_by(_id: params[:id])
  halt 404 if route.nil?
  route.to_json
end

post '/routes' do
  #debugger
  halt 400 if request.params.nil?   
  if !params['route'].nil?
    route = Route.new
    schedule = Schedule.new
    
    %w(from to route_points hitchhiker_id vehicle_id route_link available_sits).each do |key|
      unless params['route'][key].nil?
        route[key] = params['route'][key]
      end
    end
    user = Hitchhiker.find(route.hitchhiker_id)    
  else
    route = Route.new JSON.parse(request.body.to_json) 
    user = Hitchhiker.find(params[:hitchhiker_id])
  end
  
  halt 404 if user.nil?
  
  user.routes << route
  
  halt 500 unless user.save

  [201, route.to_json]
end

put '/routes/:id' do
  route = Route.find_by(_id: params[:id])
  halt 404 if route.nil?

  halt 400 if params.to_json.nil?

  %w(city country route_link avaliable_sits starting_point end_point).each do |key|
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
  #debugger
  
  route = Route.where('_id' => params[:id]).first
  halt 404 if route.nil?
  if !params['schedule'].nil?
    route_schedule = Schedule.new
    
    %w(departure arrival date).each do |key|
      unless params['schedule'][key].nil?
        route_schedule[key] = params['schedule'][key]
      end
    end
  else
  route_schedule = Schedule.new JSON.parse(request.params.to_json)
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

get '/hitchhikers/lat=:lat&long=:long' do
  users = Hitchhiker.where position: { '$near' => [ params[:long], params[:lat] ], '$maxdistance' => 5 }
  users.to_json
end

#LET'S GET SOME VEHICLES

get '/vehicles' do
  unless params[:vehicle_id].nil?
    vehicle = Vehicle.find(params[:id])
    halt 200, vehicle.to_json
  end
  Vehicle.all.to_json
end

get '/vehicles/brands' do
  brands = Vehicle.distinct(:brand)
  brands.to_json
end

get '/vehicles/:id' do 
   unless params[:id].nil?
    vehicle = Vehicle.find(params[:id])
    halt 200, vehicle.to_json
  end
end

get '/vehicles/:brand/models' do
  halt 400 if params[:brand].nil?
  models = Vehicle.where(:brand => params[:brand]).distinct(:model)
  models.to_json
end

get '/vehicles/:brand/:model/years' do
  halt 400 if params[:brand].nil? && params[:model].nil?
  years = Vehicle.where(:brand => params[:brand], :model=> params[:model]).only(:year,:_id)
  years = years.map{|a| {year: a.year, id: a.id}}
  years.to_json
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

