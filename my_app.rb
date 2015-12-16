require 'sinatra/base'
require 'rack/reverse_proxy'
require 'json'

fail "Doh! Forgot to set $SECRET_TOKEN" if ENV['SECRET_TOKEN'].nil?
fail "Doh! Forgot to set $JENKINS_HOST" if ENV['JENKINS_HOST'].nil?

class MyApp < Sinatra::Base
  # http://recipes.sinatrarb.com/p/middleware/rack_commonlogger
  configure do
    enable :logging
    $stdout.sync = true
    use Rack::CommonLogger, $stdout
  end

  post '/jenkins' do
    request.body.rewind
    payload_body = request.body.read
    logger.debug "* The payload body: #{payload_body}"
    logger.debug "* The params obj: #{params}"

    verify_signature(payload_body)

    parsed = JSON.parse(payload_body)
    logger.debug "* The parsed JSON: #{parsed.inspect}"
  end

  def verify_signature(payload_body)
    unless request.env['HTTP_X_HUB_SIGNATURE']
      logger.warn "Got request without HTTP_X_HUB_SIGNATURE"
      return halt 500, "No signature found!"
    end

    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['SECRET_TOKEN'], payload_body)

    unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
      logger.warn "Got request with incorrect signature"
      return halt 500, "Signatures didn't match!"
    end

    logger.info "Got request with correct signature"
  end

  # For any endpoints not matched
  get "/*" do
    halt_with_404_not_found
  end

  post "/*" do
    halt_with_404_not_found
  end

  put "/*" do
    halt_with_404_not_found
  end

  patch "/*" do
    halt_with_404_not_found
  end

  delete "/*" do
    halt_with_404_not_found
  end

  def halt_with_404_not_found
    halt 404, "Not found"
  end
end
