Feature: The API for Hitchhiker
  In order to generate revenue
  A Client
  Should be able to GET a list of Users

Scenario: The application gets a list of all users
  Given That i have "2" hitchhikers 
  And "1" driver
  When I visit "/users"
  Then I should see a list of "3" users  

Scenario: The application gets a list of all users who are drivers
  Given That i have "2" hitchhikers 
  And "1" driver
  When I visit "/users/drivers"
  Then I should see a list of "1" drivers  

Scenario: The application gets a list of all users who are hitchhikers
  Given That i have "2" hitchhikers 
  And "1" driver
  When I visit "/users/hitchhikers"
  Then I should see a list of "2" hitchhikers
