require_relative '../spec_helper.rb'

describe 'The Hitchhikers API' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context 'regarding users' do
    before :all do
      User.destroy_all
      5.times do |u|
        json = {}
        json['username'] = "User#{u}"
        json['hitchhiker'] = true
        json['routes'] = []
        #json['vehicles'] = []
        json['position'] = {latitude: 50.729400634765625, longitude: 15.723899841308594}
        user = User.new json
        user.save
      end
    end

    it "should give a list of all users" do
      get '/users'
      last_response.should be_ok
      json_response = JSON.parse last_response.body
      json_response.size.should eql 5
      json_response.first['username'].should eql "User0"
    end

    it "should list all drives" do
      get '/users/drivers'
      last_response.should be_ok
      json_response = JSON.parse last_response.body
      json_response.size.should eql 0  
    end

    it "should list all hitchhikers" do
      get '/users/hitchhikers'
      last_response.should be_ok
      json_response = JSON.parse last_response.body
      json_response.size.should eql 5  
    end

    it "should add users" do
      post '/users', {username: "NewUser", hitchhiker: 'false'}
      last_response.status.should eql 201
      json_response = JSON.parse last_response.body
      json_response['username'].should eql 'NewUser'
    end

    it "should be able to edit users" do
      
      old_user = User.all.entries[1]
      
      put "users/#{old_user['_id']}", {username: "Newuser1", hitchhiker: 'false'}
      last_response.status.should eql 204
      User.find_by(_id: old_user['_id'])['username'].should_not eql old_user['username']
    end

    it "should be able to delete users" do

      users_count = User.all.entries.size

      delete "/users/#{User.all.entries[1]['_id']}"
      last_response.status.should eql 200
      
      User.all.entries.size.should eql users_count -1
    end
  end

  context 'regarding users location' do
    it "should be able to get all users within reach" do
      user = User.new username: "Searching User", hitchhiker: false, position: {latitude: 50.729400634765625, longitude: 15.723899841308594}
       #debugger

      get "/users/lat=#{user.position[:longitude]}&long=#{user.position[:latitude]}"
      #get "/users/lat"
      
      # debugger
      last_response.status.should eql 200
      # last_response.body.should
    end
    it "should be able to get all drivers within reach"
    it "should be able to get all hitchhikers within reach"
  end

  context 'regarding routes' do
     
     before :all do
      Route.destroy_all
      Vehicle.destroy_all
      
      @user = User.first()
      @vehicle = Vehicle.new  brand: "Honda", model: "Civic", year:2008, sits:5, hasTrunk: false 
      @vehicle.save 
      5.times do |u|
        json = {}
        json['country'] = "Country#{u}"
        json['city'] = "City#{u}"
        json['routeLink'] = "http://#{u}.com"
        json['vehicle'] = @vehicle
        json['passengers'] = []
        json['avaliableSits'] = u
        json['startingPoint'] = {latitude: 50.729400634765625 - u, longitude: 15.723899841308594 +  u}
        json['endPoint'] = {latitude: 50.729400634765625 - u, longitude: 15.723899841308594 + u}
        route = Route.new json
        @user.routes << route
        @user.save      
      end
    end
    
    it 'should add a route'  do
      post '/users/'+@user.username+'/routes', {city: "New User", 
                             country: 'false', 
                             routeLink: '', 
                             avaliableSits: 2,
                             startingPoint: {long: 50.729400634765625, lat: 15.723899841308594},
                             endPoint: {long: 50.729600634765625, lat: 15.723999841308594}
                             }
      last_response.status.should eql 201
      json_response = JSON.parse last_response.body
      json_response['username'].should eql @user.username
    end
    
    it 'should list routes by username' do
      
      get '/users/'+@user.username+'/routes'
      last_response.should be_ok
      json_response = JSON.parse last_response.body
      json_response.size.should eql 6  
    end
    
    it 'should edit a route' do
      old_route = @user.routes.first()
      #debugger
      put "/routes/#{old_route['_id']}", {city: "Distrito Nacional", 
                             country: 'Republica Dominicana', 
                             routeLink: 'http://testlink.com',
                             avaliableSits: 3, 
                             startingPoint: {long: 50.729400634765625, lat: 15.723899841308594},
                             endPoint: {long: 50.729600634765625, lat: 15.723999841308594}
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
      post "/routes/#{route.id}/schedule", {departure: Time.now, 
                                   arrival: Time.now + 1, 
                                   date: Date.today
                             }
      last_response.status.should eql 201
      
      json_response = JSON.parse last_response.body
      json_response['schedule']['date'].should eql '2013-07-02'
      
    end
    
    it  'should let to update a route schedule'  do
      route = @user.routes.first()
      post "/routes/#{route.id}/schedule", {departure: Time.now, 
                                   arrival: Time.now + 1, 
                                   date: Date.today-1
                             }
      last_response.status.should eql 201
      
      json_response = JSON.parse last_response.body
      json_response['schedule']['date'].should eql '2013-07-01'
    end
      
    
    
    it  'should let to delete a route schedule'  do
      route = @user.routes.first()

      delete "/routes/#{route.id}/schedule"
      last_response.status.should eql 200
      
      Route.where(:id => route.id).first().schedule.should be_nil
      
    end
      
    it 'should let to add a stop in a route'
    it 'should let to update a stop in a route'
    it 'should let to delete a stop in a route' 
      
    
    it 'should let passengers check into a route' do
      route = @user.routes.where(:avaliableSits => 1).first()
      put "/routes/#{route.id}/checkin", {user_id: User.last().id}
      last_response.status.should eql 204
      Route.where(:id => route.id).first().passengers.size.should eql 1
    end
    
    it 'should deny a passenger entry if car is full' do
      route = @user.routes.where(:avaliableSits => 1).first()
      put "/routes/#{route.id}/checkin", {user_id: User.last().id}
      last_response.status.should eql 403
      Route.where(:id => route.id).first().passengers.size.should eql 1
    end
    
  end
end