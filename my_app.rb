require 'sinatra/base'
require 'rack/reverse_proxy'
require 'json'

fail "Doh! Forgot to set $SECRET_TOKEN" if ENV['SECRET_TOKEN'].nil?
fail "Doh! Forgot to set $JENKINS_HOST" if ENV['JENKINS_HOST'].nil?

class MyApp < Sinatra::Base
  post '/jenkins' do
    request.body.rewind
    payload_body = request.body.read
    puts "* The payload body: #{payload_body}"
    puts "* The params obj: #{params}"
    verify_signature(payload_body)
    parsed = JSON.parse(payload_body)
    puts "* The parsed JSON: #{parsed.inspect}"
  end

  def verify_signature(payload_body)
    # 500 if request doesn't even have HTTP_X_HUB_SIGNATURE in the header
    return halt 500, "Invalid request!" unless request.env['HTTP_X_HUB_SIGNATURE']
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['SECRET_TOKEN'], payload_body)
    return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
  end
end
