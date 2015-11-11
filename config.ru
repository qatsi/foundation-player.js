#\ -s puma -p 8889
# Require and configure LiveReload for static content server
require 'rack-livereload'
map '/' do
  use Rack::LiveReload, no_swf: true, min_delay: 0, max_delay: 50
  use Rack::Static, urls: [''], root: '.', index: 'index.html'
  run lambda { |*| }
end
