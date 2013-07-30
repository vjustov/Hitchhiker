# puts File.dirname(__FILE__)
# puts File.join File.absolute_path(__FILE__), '..', '..', 'config.rb'

require File.join File.absolute_path(__FILE__), '..', '..', 'config.rb'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) can be set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html
# puts 'ROLES'
# YAML.load(ENV['ROLES']).each do |role|
#   Role.mongo_session['roles'].insert({ :name => role })
#   puts 'role: ' << role
# end
puts 'VEHICLES'
vehicle = {}
File.open File.dirname(__FILE__) + '/Cars.json', 'r' do |f|
  JSON.load(f).each do |maker|
    # puts maker['models']
    maker_name = maker['title']
    maker['models'].each do |model|
      model_name = model['title']
      vehicle['brand'] = maker_name
      vehicle['model'] = model_name
      # puts vehicle
      v = Vehicle.new vehicle
      v.save!
    end
  end
end

# puts 'DEFAULT USERS'
# # user = User.create! :name => ENV['ADMIN_NAME'].dup, :email => ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => ENV['ADMIN_PASSWORD'].dup
# puts 'user: ' << user.name
# user.add_role :admin