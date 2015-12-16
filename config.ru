require 'rack/reverse_proxy'

use Rack::ReverseProxy do
  # Set :preserve_host to true globally (default is true already)
  reverse_proxy_options preserve_host: true

  # Forward the path /test* to http://example.com/test*
  reverse_proxy '/test', 'http://example.com/'

  # Forward the path /foo/* to http://example.com/bar/*
  reverse_proxy /^\/foo(\/.*)$/, 'http://example.com/bar$1', username: 'name', password: 'basic_auth_secret'
end

app = proc do |env|
  [ 200, {'Content-Type' => 'text/plain'}, "Hello World ! " ]
end
run app
