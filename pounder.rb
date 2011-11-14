require 'rubygems'
require 'bundler/setup'
require 'faker'
require 'uri'
require 'net/http'

def newpass( len = 8 )
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
end

config = YAML.load_file("pounder.yml")

config.each do |site|
  s = site['site']
  uri = URI.parse(s['url'] + s['action'])
  request = Net::HTTP::Post.new(uri.request_uri)
  threads = []
  (1..50).each do 
    threads << Thread.new() { 
      http = Net::HTTP.new(uri.host, uri.port)
      username = Faker::Internet.email
      pass = newpass
      request.set_form_data({s['username'] => pass, s['password'] => pass})
      response = http.request(request)
      p "#{username}:#{pass} [ #{response.message} ]"
    }
  end
  threads.each { |aThread|  aThread.join }
end

