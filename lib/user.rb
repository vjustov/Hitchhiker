require_relative '../config.rb'

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :username, type: String
  field :hitchhiker, type: Boolean

  field :position, type: Hash

  index ({position:"2d"})

  
  scope :hitchhikers, where(hitchhiker: true)
  scope :drivers, where(hitchhicker: false)
  scope :by_username, ->(username) { where(:username => username)}
  scope :near, ->(long,lat) { where(:position=> { '$near' => [ params[:long], params[:lat] ], '$maxdistance' => 5 })}

  #has_and_belongs_to_many :vehicles, inverse_of: nil 
  #has_many :vehicles 
  has_many :routes

end
