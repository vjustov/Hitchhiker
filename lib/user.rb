require 'mongoid'

class User
  include Mongoid::Document
  # field :user_id, type: Integer
  field :username, type: String
  field :hitchhiker, type: Boolean

  # validates_uniqueness_of :user_id
  # validates_numericality_of :user_id, only_integer: true
end