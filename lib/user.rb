require 'mongoid'

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # field :user_id, type: String
  field :username, type: String
  field :hitchhiker, type: Boolean
  field :position, type: Hash
  index { position: "2d" }
  # index :user_id
  # index({user_id: 1}, {unique: true})
  # validates_uniqueness_of :user_id
  # validates_numericality_of :user_id, only_integer: true

  # def Generate_id _id
  #   [[_id].pack("H*")].pack("m").strip
  # end


end

