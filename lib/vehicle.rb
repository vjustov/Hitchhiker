class Vehicle 
  include Mongoid::Document
  
  field :brand, type: String
  field :model, type: String
  field :year, type: Integer
  field :sits, type: Integer
  field :has_trunk, type: Boolean
  
  
  has_many :routes
  has_many :hitchhikers, inverse_of: :hitchhikers
end