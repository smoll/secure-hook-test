require './my_app'

# Use Sinatra app as Middleware
use MyApp
use Rack::ReverseProxy do
  # Set :preserve_host to true globally (default is true already)
  reverse_proxy_options preserve_host: true

  # Forward the path /jenkins* to e.g. http://jenkins.company.tld/*
  reverse_proxy '/jenkins', "http://#{ENV['JENKINS_HOST']}/"
end

app = proc do |env|
  [ 200, {'Content-Type' => 'text/plain'}, "ok" ]
end
run app
