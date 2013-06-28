require_relative '../config.rb'

class Route
  include Mongoid::Document
  
  field :city, type: String
  field :country, type: String
  
  field :routeLink, type: String
  field :startingPoint, type: String
  field :endPoint, type: String  
  field :routePoints, type:Array
  
  belongs_to :vehicle
  field :passengers, type:Array
  
  embeds_many :stops
  embeds_in :user
  embeds_one :schedule
end

class Schedule
  include Mongoid::Document
  
  field :departure, type:Time, presence: true
  field :arrival, type:Time 
  
  field :date, type: String, presence: true
  field :frecuency, type:Integer
  
  embeds_in :route
end

class Stop
  include Mongoid::Document
  
  field :duration, type: Integer
  embeds_in :route  
  embeds_one :location
   
end

class Location
  include Mongoid::Document
  
   field :lng, type: Float
   field :lat, type: Float
  
  embeds_in :stop
  
end
