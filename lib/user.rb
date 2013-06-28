require 'mongoid'

class User
  include Mongoid::Document
  field :username, type: String
  field :hitchhiker, type: Boolean
end