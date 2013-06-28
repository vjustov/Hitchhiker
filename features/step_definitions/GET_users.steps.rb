#include Rack::Test::Methods

Transform /^(-?\d+)$/ do |number|
  number.to_i
end

Given /That i have "(.*)" hitchhikers/ do |hh_qnty|
  hh_qnty.to_i.times do |c|
    hitchhiker = User.new  username: "Hitchhiker #{c.to_s}", hitchhiker: true 
    hitchhiker.save
  end
end

And /"(.*)" driver/ do |d_qnty|
  d_qnty.to_i.times do |c|
    driver = User.new username: "Hitchhiker #{c.to_s}", hitchhiker: true 
    driver.save
  end
end

When /I visit "(.*)"/ do |url|
  get '/'
end

Then /I should see a list of "(.*)" users/ do |u_qnty|
  response_body.size.should = u_qnty
end

Then /I should see a list of "(.*)" drivers/ do |d_qnty|
  response_body.size.should = d_qnty
end

Then /I should see a list of "(.*)" hitchhikers/ do |hh_qnty|
  response_body.size.should = hh_qnty
end
