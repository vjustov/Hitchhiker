Given /That i have "(,*)" users/ do |user_qnty|
  pending "#Need the post to add the users"
end

When /I make a "(.*)" request in "(.*)"/ do |method, url|
  visit(url)
end

Then /I should see a list of all users/ do
  response_body.size.should = 3
end
