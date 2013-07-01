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
        json['username'] = "User #{u}"
        json['hitchhiker'] = true
        user = User.new json
        user.save
      end
    end

    it "should give a list of all users" do
      get '/users'
      last_response.should be_ok
      json_response = JSON.parse last_response.body
      json_response.size.should eql 5
      json_response.first['username'].should eql "User 0"
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
      post '/users', {username: "New User", hitchhiker: 'false'}
      last_response.status.should eql 201
      json_response = JSON.parse last_response.body
      json_response['username'].should eql 'New User'
    end

    it "should be able to edit users" do
      
      old_user = User.all.entries[1]
      
      put "users/#{old_user['_id']}", {username: "New user 1", hitchhiker: 'false'}
      last_response.status.should eql 204
      User.find_by(_id: old_user['_id'])['username'].should_not eql old_user['username']
    end

    it "should be able to delete users" do

      users_count = User.all.entries.size

      delete "/users/#{User.all.entries[1]['_id']}"
      last_response.status.should eql 200
      
      User.all.entries.size.should eql users_count -1
    end

    it "should be able to get all users within reach"


  end

  context 'regarding users location' do

  end
end