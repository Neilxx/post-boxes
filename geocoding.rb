require 'rest-client'
require 'nokogiri'
require 'awesome_print'
require 'redis'
require 'open-uri'
require 'pry'
require 'json'


file = File.read('public/post_boxes.json')
post_boxes = JSON.parse(file)
post_boxes.each do |post_box|
  address = post_box["full_address"]
  pry.binding
  address = CGI.escape  address.to_s
  url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{address}&key=AIzaSyANrwP97rB6-tun03pB8yY3NPd3di2BRTI"
  response = RestClient.get url, :user_agent => "myagent"
  response_json = JSON.parse(response)
  post_box["lat"] = response_json["results"][0]["geometry"]["location"]["lat"] 
  post_box["lng"] = response_json["results"][0]["geometry"]["location"]["lng"] 
  pry.binding
end

File.open("public/post_boxes_with_latlng.json","w") do |f|
  f.write(post_boxes.to_json)
end
