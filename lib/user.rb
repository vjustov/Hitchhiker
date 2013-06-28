require_relative '../config.rb'

class User
  include Mongoid::Document
  field :username, type: String
  field :hitchhiker, type: Boolean
  has_and_belongs_to_many :vehicles, inverse_of: nil 
end