require_relative '../spec_helper.rb'

describe 'The Hitchhikers API' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  context 'regarding the fb interconnection' do
    it 'should log in with the facebook credentials'
    it "should get a list of all the user's friends"
  end
  
  context 'regarding API OAUTH2' do
    
    before :all do
      oauth2 = YAML.load_file(File.join(File.dirname(__FILE__),'..','oauth2.yml'))
      @secret = oauth2['client_secret']


      Rack::OAuth2::Server.new :database => Mongo::Connection.new["API_TEST"]
      Rack::OAuth2::Server.register(id: oauth2['client_id'], 
                                    secret: oauth2['client_secret'], 
                                    display_name: oauth2['display_name'], 
                                    link: oauth2['link'], 
                                    redirect_uri: oauth2['redirect_uri'], 
                                    scope: oauth2['scope'].split)
                                    
     @code = Rack::OAuth2::Server.access_grant(oauth2['client_id'],oauth2['client_id'],oauth2['scope'])
     post '/oauth/access_token', {grant_type: "authorization_code", 
                                 code: @code,
                                 redirect_uri: oauth2['redirect_uri'],
                                 client_id: oauth2['client_id'],
                                 client_secret: oauth2['client_secret']
                                }
    @token = JSON.parse(last_response.body) if last_response.status = 200                                
         
    end
    
    
    it 'should authorized a client already registered' do
      get "/?oauth_token=#{@token['access_token']}"
      last_response.should be_ok
    end 
    
    it 'should return Unauthorized [401], if a valid token is not sent in the resquest' do
      get "/"
      last_response.status.should eql(401) 
    end 
                                  
  end

  context 'regarding users' do
    before :all do
      Hitchhiker.destroy_all
      5.times do |u|
        json = {}
        json['username'] = "Hitchhiker#{u}"
        json['hitchhiker'] = true
        json['email'] = "email#{u}@test.com"
        json['name'] = "name#{u}"
        json['lastname'] = "lastname#{u}"
        json['password'] = "password#{u}"
        json['admin'] = u.even?
        json['routes'] = []
        #json['vehicles'] = []
        json['position'] = {latitude: 50.729400634765625, longitude: 15.723899841308594}
        user = Hitchhiker.new json
        user.save
      end
    end

    it "should give user data" do
      @user = Hitchhiker.first()
      get "/hitchhikers?username=#{@user.username}"
      last_response.should be_ok
      user = JSON.parse(last_response.body)
      user['username'] = @user.username
    end

    it "should give a list of all users" do
      get '/hitchhikers'
      last_response.should be_ok
      json_response = JSON.parse last_response.body
      json_response.size.should eql 5
      json_response.first['username'].should eql "Hitchhiker0"
    end



    it "should list all drives" do
      get '/hitchhikers/drivers'
      last_response.should be_ok
      json_response = JSON.parse last_response.body
      json_response.size.should eql 0  
    end

    it "should list all hitchhikers" do
      get '/hitchhikers/hitchhikers'
      last_response.should be_ok
      json_response = JSON.parse last_response.body
      json_response.size.should eql 5  
    end


    it "should login a user" do
      user = Hitchhiker.all.entries[1]
      get "/login", {username: user.username, password: user.password}
      last_response.should be_ok
        
    end
    
    it "should add users" do
      post '/hitchhikers', {
        username: "NewHitchhiker",
        hitchhiker: true,
        email: "newuser@test.com",
        name: "new",
        lastname: "user",
        password: "passwordLast",
        admin: false,
        routes: []}
      last_response.status.should eql 201
      json_response = JSON.parse last_response.body
      json_response['username'].should eql 'NewHitchhiker'
    end

    it "should be able to edit users" do
      
      old_user = Hitchhiker.all.entries[1]
      
      put "/hitchhikers/#{old_user.username}", {lastname: 'Updated', hitchhiker: false}
      last_response.status.should eql 204
      Hitchhiker.by_username(old_user.username).first()['lastname'].should_not eql old_user['lastname']
    end

    it "should be able to delete users" do

      users_count = Hitchhiker.all.entries.size

      delete "/hitchhikers/#{Hitchhiker.all.entries[1]['username']}"
      last_response.status.should eql 200
      #debugger
      Hitchhiker.all.entries.size.should eql users_count -1
    end
  end

  context "Let's get some vehicles" do

    before :all do
      Vehicle.destroy_all
      year = 2010
      5.times do |c|
        vehicle = Vehicle.new(brand: 'Toyota', model: 'Camry', year: year + c, sits: 4, has_trunk: true)
        vehicle.save
      end
      vehicle2 = Vehicle.new(brand: 'Toyota', model: 'Corolla', year: year, sits: 4, has_trunk: false)
      vehicle2.save

      vehicle3 = Vehicle.new(brand: 'Honda', model: 'CRV', year: year, sits: 4, has_trunk: false)
      vehicle3.save
    end

    it 'should get all the vehicles' do
      get '/vehicles'
      last_response.should be_ok
      vehicles = JSON.parse(last_response.body)
      vehicles.size.should eql 7
    end

    it 'should get a vehicle' do
      get "/vehicles/#{Vehicle.first.id}"
      last_response.should be_ok
    end

    it 'should get all brands' do
      get '/vehicles/brands'
      last_response.should be_ok
      brands = JSON.parse(last_response.body)
      brands.size.should eql 2
    end

    it 'should get all model from brand' do
      get "/vehicles/Toyota/models"
      last_response.should be_ok
      models = JSON.parse(last_response.body)
      models.size.should eql 2
    end

    it 'should get all years and ids from model and brand' do
      vehicle = Vehicle.first
      get "/vehicles/#{vehicle.brand}/#{vehicle.model}/years"
      last_response.should be_ok
      years = JSON.parse(last_response.body)
      years.size.should eql 5
    end

  end


  context 'regarding users location' do
    it "should be able to get all users within reach" do
      user = Hitchhiker.new username: "Searching Hitchhiker", hitchhiker: false, position: {latitude: 50.729400634765625, longitude: 15.723899841308594}
       #debugger

      get "/hitchhikers/long=#{user.position[:longitude]}&lat=#{user.position[:latitude]}"
      get "/hitchhikers/lat=#{user.position[:longitude]}&long=#{user.position[:latitude]}"
      #get "/hitchhikers/lat"
      
      # debugger
      last_response.status.should eql 200

      json_response = JSON.parse last_response.body
      json_response.size.should eql 4
    end
    it "should be able to get all drivers within reach"
    it "should be able to get all hitchhikers within reach"
  end

  context 'regarding routes' do
     
     before :all do
      Route.destroy_all
      #Vehicle.destroy_all
      Schedule.destroy_all
      
      @user = Hitchhiker.first()
      @vehicle = Vehicle.new  brand: "Honda", model: "Civic", year:2008, sits:5, has_trunk: false 
      @vehicle.save 
      5.times do |u|
        json = {}
        json['country'] = "Country#{u}"
        json['city'] = "City#{u}"
        json['from'] = "micasa#{u}"
        json['to'] = "tucasa#{u}"
        json['route_link'] = "http://#{u}.com"
        json['vehicle'] = @vehicle
        json['passengers'] = []
        json['stops'] = []
        json['available_sits'] = u
        json['starting_point'] = {latitude: 50.729400634765625 - u, longitude: 15.723899841308594 +  u}
        json['end_point'] = {latitude: 50.729400634765625 - u, longitude: 15.723899841308594 + u}
        route = Route.new json
        @user.routes << route
        @user.save      
      end
    end

    it 'should give a list of all active routes' do
      get '/routes'
      last_response.should be_ok
      routes = JSON.parse(last_response.body)
      routes.size.should eql 5
    end

    it 'should give the detail of a route' do
      route = @user.routes.first()
      get "/routes/#{route.id}"

      last_response.should be_ok
      result = JSON.parse(last_response.body)
      result['country'].should eql route.country
    end
    
    it 'should add a route'  do
      post '/hitchhikers/'+@user.username+'/routes', {city: "New Hitchhiker", 
                             country: 'false', 
                             route_link: '',
                             from: 'alameda',
                             to: 'herrera', 
                             available_sits: 2,
                             starting_point: {long: 50.729400634765625, lat: 15.723899841308594},
                             end_point: {long: 50.729600634765625, lat: 15.723999841308594}
                             }
      last_response.status.should eql 201
      json_response = JSON.parse last_response.body
      json_response['username'].should eql @user.username
    end
    
    it 'should list routes by username' do
      
      get '/hitchhikers/'+@user.username+'/routes'
      last_response.should be_ok
      json_response = JSON.parse last_response.body
      json_response.size.should eql 6  
    end
    
    it 'should edit a route' do
      old_route = @user.routes.first()
      #debugger
      put "/routes/#{old_route['_id']}", {city: "Distrito Nacional", 
                             country: 'Republica Dominicana', 
                             route_link: 'http://testlink.com',
                             available_sits: 3, 
                             starting_point: {long: 50.729400634765625, lat: 15.723899841308594},
                             end_point: {long: 50.729600634765625, lat: 15.723999841308594}
                             }
      last_response.status.should eql 204
      Route.find_by(_id: old_route['_id'])['city'].should_not eql old_route['city']
      
      
    end
   
    
    it' should delete a route' do
      route_count = Route.all.entries.size

      delete "/routes/#{Route.first()['_id']}"
      last_response.status.should eql 200
      
      Route.all.entries.size.should eql route_count-1
    end
    
    it  'should let to set the route schedule' do
       route = @user.routes.first()

      post "/routes/#{route.id}/schedule", {departure: 5.hours.ago, arrival: 3.hours.ago,
                                            date: Date.today
                             }
      last_response.status.should eql 201
      
      json_response = JSON.parse last_response.body
      json_response['schedule']['date'].to_date.should eql Date.today.to_date
      
    end
    
    it 'should not allow to set schedule within the same route timeframe' do
      route = @user.routes.skip(1).first()

      post "/routes/#{route.id}/schedule", {departure: 2.hours.ago, arrival: Time.now,
                                            date: Date.today}
      last_response.status.should eql 403
      
    end
    
    it  'should let to update a route schedule'  do
      route = @user.routes.first()

      put "/routes/#{route.id}/schedule", {departure:  2.hours.ago, arrival: Time.now,
                                   date: Date.today-1
                             }
      last_response.status.should eql 204
    end
      
    
    
    it  'should let to delete a route schedule'  do
      route = @user.routes.first()

      #delete "/routes/#{route.id}/schedule"
      last_response.status.should eql 200
      
      Route.where(:id => route.id).first().schedule.should be_nil
      
    end
      
    it 'should let to add a stop in a route' do 
      route = @user.routes.first()
      post "/routes/#{route.id}/stops", {duration:5, position: {long: 50.729600634765625, lat: 15.723999841308594 } }
      
      last_response.status.should eql 201
      json_response = JSON.parse last_response.body
      json_response.first()['duration'].should eql 5  
      
    end
    
    it 'should let to update a stop in a route' do 
      route = Route.first()
      
      put "/routes/#{route.id}/stops/#{route.stops.first().id}", {duration:3, position: {long: 50.739600634765625, lat: 15.733999841308594 } }
      
      last_response.status.should eql 204
      Route.find_by(_id: route.id).stops.first().duration.should_not eql route.stops.first().duration
            
    end
    
    it 'should let to delete a stop in a route' do
     route = Route.first()

      delete "/routes/#{route.id}/stops/#{route.stops.first().id}"
      last_response.status.should eql 200
      
      Route.where(:id => route.id).first().stops.size.should eql route.stops.size-1 
    end
    
    it 'should let passengers check into a route' do
      route = @user.routes.where(:available_sits => 1).first()
      put "/routes/#{route.id}/checkin", {user_id: Hitchhiker.last().id}
      last_response.status.should eql 204
      Route.where(:id => route.id).first().passengers.size.should eql 1
    end
    
    it 'should deny a passenger entry if car is full' do
      route = @user.routes.where(:available_sits => 1).first()
      put "/routes/#{route.id}/checkin", {user_id: Hitchhiker.last().id}
      last_response.status.should eql 403
      Route.where(:id => route.id).first().passengers.size.should eql 1
    end
    
    it 'should not allowed a passenger to checkin two routes in the same timeframe' do

    end
    
    it 'a user need to see what routes it is checkin on'
    
    
  end
end