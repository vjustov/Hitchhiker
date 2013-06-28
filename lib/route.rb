require_relative '../config.rb'

class Route
  include Mongoid::Document
  
  
  embeds_many :stops
  embeds_in :trip
end

class Trip
  include Mongoid::Document
  
  field :isRoundTrip, type: Boolean
  
  
  embeds_in :user
  embeds_one :schedule
  embeds_many :routes
end

class Stop
  include Mongoid::Document
  
  field :duration, type: Integer  
  embeds_one :location
   
end

class Location
  include Mongoid::Document
  
   field :lng, type: Float
   field :lat, type: Float
  
  embeds_in :stop
  
end
