
require './config'
require './app'
use Rack::MethodOverride

app = Rack::Builder.new do
    map("/oauth/admin") do 
       #Rack::OAuth2::Server.set :options, Rack::OAuth2::Server::Options.new(:database=> Mongo::Connection.new["API_TEST"])  
       run Rack::OAuth2::Server::Admin 
     end
    map("/") do
       run Sinatra::Application
     end

  end
Rack::OAuth2::Server::Admin.set :client_id, "51da4f0b66b0aa3ea6000001"
Rack::OAuth2::Server::Admin.set :client_secret, "8d979a271c08146cdff56da77110cd2b2c39fa8edf11708413cfbffdc04c6cc4"
Rack::OAuth2::Server::Admin.set :scope, %w{read write}
Rack::OAuth2::Server::Admin.set :force_ssl, false
 run app