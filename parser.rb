require 'rest-client'
require 'nokogiri'
require 'awesome_print'
require 'redis'
require 'open-uri'
require 'pry'
require 'json'

#$ssdb = Redis.new(port: 8888, timeout: 300)
post_boxes = []
#用RestClient取HTML的body
city_with_district_part1 = {
  '基隆市': ['仁愛區','信義區','中正區','中山區','安樂區','暖暖區','七堵區'],
  '臺北市': ['中正區','大同區','中山區','松山區','大安區','萬華區','信義區','士林區','北投區','內湖區','南港區','文山區'],
}
city_with_district_part1.each do |city, districts|
  districts.each do |district|
    en_city = CGI.escape city.to_s
    en_district = CGI.escape district.to_s
    url = "https://www.post.gov.tw/post/internet/I_location/index.jsp?topage=1&PreRowDatas=10&city=#{en_city}&city_area=#{en_district}&ID=190106&village=&addr="
    #.force_encoding("utf-8")
    #.force_encoding('ASCII-8BIT')
    htmlData = RestClient.get url, :user_agent => "myagent"
    response = Nokogiri::HTML(htmlData.body)
    response.css('table tr').each_with_index do |row, index|
      next if index == 0
      post_box = {
        city: city.to_s,
        district: district.to_s,
        block: row.css('td:nth-child(2)').text,
        road: row.css('td:nth-child(3)').text,
      } 
      post_box["full_address"] = "#{post_box[:city]}#{post_box[:district]}#{post_box[:block]}#{post_box[:road]}"
      post_boxes << post_box
    end
    sleep 1
  end
end
File.open("public/post_boxes.json","w") do |f|
  f.write(post_boxes.to_json)
end

