require_relative '../config.rb'

class Route
  include Mongoid::Document
  
  field :city, type: String
  field :country, type: String
  
  field :routeLink, type: String
  field :startingPoint, type: Hash
  field :endPoint, type: Hash  
  field :routePoints, type:Array
  field :avaliableSits, type:Integer
  
  belongs_to :vehicle
  field :passengers, type:Array
  
  embeds_many :stops
  belongs_to :user
  embeds_one :schedule
end

class Schedule
  include Mongoid::Document
  
  field :departure, type:Time
  field :arrival, type:Time 
  
  field :date, type: String
  field :frecuency, type:Integer
  
  validates_presence_of :departure
  validates_presence_of :date
  
  embedded_in :route
end

class Stop
  include Mongoid::Document
  
  field :duration, type: Integer
  embedded_in :route  
  embeds_one :location
   
end

class Location
  include Mongoid::Document
  
   field :lng, type: Float
   field :lat, type: Float
  
  embedded_in :stop
  
end
