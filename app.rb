require 'sinatra'
require 'rack/reverse_proxy'
require 'json'

fail "Doh! Forgot to set $SECRET_TOKEN" if ENV['SECRET_TOKEN'].nil?

use Rack::ReverseProxy do
  # Set :preserve_host to true globally (default is true already)
  reverse_proxy_options preserve_host: true

  # Forward the path /test* to http://example.com/test*
  reverse_proxy '/test', 'http://example.com/'
end

post '/payload' do
  request.body.rewind
  payload_body = request.body.read
  puts "* The payload body: #{payload_body}"
  puts "* The params obj: #{params}"
  verify_signature(payload_body)
  push = JSON.parse(payload_body)
  puts "* I got some JSON: #{push.inspect}"
end

def verify_signature(payload_body)
  # 500 if request doesn't even have HTTP_X_HUB_SIGNATURE in the header
  return halt 500, "Nope!" unless request.env['HTTP_X_HUB_SIGNATURE']
  signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['SECRET_TOKEN'], payload_body)
  return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
end
