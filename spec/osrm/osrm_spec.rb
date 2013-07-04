require_relative '../spec_helper.rb'

describe 'OSRM API Communication' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context 'GET /osrm/routes' do
  	it "should be able to get a route indicating from-to" do
  		#HAPPY PATH
  		get "/osrm/routes",{:from => '51.500,0.100', :to => '51.500,0.1001'}
  		last_response.should be_ok

  		#SAD/BAD PATH
		get "/osrm/routes",{:from => '51.500,0.100'}
		last_response.status.should eql 400

		get "/osrm/routes",{:from => '51.500,0.1001', :to => '51.500,0.1001'}
		last_response.status.should eql 400
  	end

  	it "should be able to choose multiple nodes for a single route" do
  		#HAPPY PATH
 		get "/osrm/routes-multiple",:locations =>{:loc1=>"51.500,0.100", :loc2=> "51.500,0.1002"}
 		last_response.should be_ok

 		#SAD/BAD PATH
		get "/osrm/routes-multiple",{}
		last_response.status.should eql 400
  	end

  	
  end
end