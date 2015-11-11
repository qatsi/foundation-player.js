Jasmine.configure do |config|
  require 'rack-livereload'
  config.server_port = 8888
  config.add_rack_app(Rack::LiveReload,
                      no_swf: true,
                      min_delay: 0,
                      max_delay: 10)
end
