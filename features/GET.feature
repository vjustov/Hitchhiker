Feature: The API for Hitchhiker
  In order to generate revenue
  A Client
  Should be able to GET a list of Users

Scenario: The application gets a list of all users
  Given That i "3" user 
  When I make a "GET" request in "/users"
  Then I should see a list of all users  

Scenario: The application gets a list of all users who are drivers
  Given That i "3" users and only one is a driver 
  When I make a "GET" request in "/users"
  Then I should see a list of all drivers  

Scenario: The application gets a list of all users who are hitchhikers
  Given That i "3" users and two are hitchhikers 
  When I make a "GET" request in "/users"
  Then I should see a list of all hitchhikers