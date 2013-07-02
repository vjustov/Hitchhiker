require_relative '../config.rb'

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # field :user_id, type: String
  field :username, type: String
  field :hitchhiker, type: Boolean
  #has_and_belongs_to_many :vehicles, inverse_of: nil 
  
  field :position, type: Hash
  index { position: "2d" }


end
