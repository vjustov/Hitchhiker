ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'user.rb')
Mongoid.load! File.join(File.dirname(__FILE__), '..', '..','mongoid.yaml')

require 'rspec'
require 'rack/test'

class Hitchhiker_APIWorld
  include RSpec::Expectations
  include Rspec::Matchers
  include Rack::Test::Methods
end

World do
  Hitchhiker_APIWorld.new
end