require_relative '../config.rb'

class Route
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :city, type: String
  field :country, type: String
  field :from, type: String
  field :to, type: String 
  
  field :route_link, type: String
  field :starting_point, type: Hash
  field :end_point, type: Hash  
  field :route_points, type:Array

  field :available_sits, type:Integer
  field :active, type:Boolean, default: true
  
  belongs_to :vehicle
  field :passengers, type:Array

  embeds_many :stops
  belongs_to :user
  embeds_one :schedule

  scope :active_routes, where(active: true)
end

class Schedule
  include Mongoid::Document
  

  field :departure, type:DateTime
  field :arrival, type:DateTime 
  
  field :date, type: String
  field :frecuency, type:Integer

  validates_presence_of :departure
  validates_presence_of :date
  
  embedded_in :route
end

class Stop
  include Mongoid::Document
  
  field :duration, type: Integer
  field :position, type: Hash
  embedded_in :route  
  #embeds_one :location
   
end

class Location
  include Mongoid::Document
  
   field :lng, type: Float
   field :lat, type: Float
  
  embedded_in :stop
  
end
