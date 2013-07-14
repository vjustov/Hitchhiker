class Vehicle 
  include Mongoid::Document
  
  field :brand, type: String
  field :model, type: String
  field :year, type: Integer
  field :sits, type: Integer
  field :hasTrunk, type: Boolean
  
  
  has_many :routes
  has_many :hitchhikers
end