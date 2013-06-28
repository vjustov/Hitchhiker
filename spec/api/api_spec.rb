require_relative '../spec_helper.rb'

describe 'The Hitchhikers API' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before :all do
    User.destroy_all
    debugger
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
    debugger
    json_response.size.should eql 5
  end

  it "should list all drives"

  it "should list all hitchhikers"
end