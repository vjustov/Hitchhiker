require_relative '../config.rb'

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # field :user_id, type: String
  field :username, type: String
  field :hitchhiker, type: Boolean

  #has_and_belongs_to_many :vehicles, inverse_of: nil 

  field :position, type: Hash


  # index :user_id
  # index({user_id: 1}, {unique: true})
  # validates_uniqueness_of :user_id
  # validates_numericality_of :user_id, only_integer: true

  # def Generate_id _id
  #   [[_id].pack("H*")].pack("m").strip
  # end


end