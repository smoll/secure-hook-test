require 'sinatra'
require 'rack/reverse_proxy'
require 'json'

use Rack::ReverseProxy do
  # Set :preserve_host to true globally (default is true already)
  reverse_proxy_options preserve_host: true

  # Forward the path /test* to http://example.com/test*
  reverse_proxy '/test', 'http://example.com/'
end

post '/payload' do
  request.body.rewind
  payload_body = request.body.read
  puts "I got something: #{payload_body}"
  # push = JSON.parse(params[:payload])
  # puts "I got some JSON: #{push.inspect}"
end
