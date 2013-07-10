require_relative '../config.rb'

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :lastname, type:String
  field :username, type: String
  field :email, type: String
  field :password, type: String
  field :image, type: String
  field :admin, type: Boolean
  #field :fb_access, type:String
  
    
  field :hitchhiker, type: Boolean
  field :position, type: Hash

  index ({position:"2d"})


  #has_and_belongs_to_many :vehicles, inverse_of: nil 
  #has_many :vehicles 
  has_many :routes

end
