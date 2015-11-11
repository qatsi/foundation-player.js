# Compile HAML
guard :haml, notifications: true do
  watch(/^.+(\.haml)$/)
end

# Compass
guard :compass, project_path: '.', compile_on_start: true do
  watch(%r{.*\.scss$})
end

# Compile CoffeeScript and uglify JavaScript
coffeescript_options = {
  input: 'src',
  output: 'src',
  patterns: [%r{^src/(.+\.(?:coffee|coffee\.md|litcoffee))$}]
}

group :js, halt_on_fail: true do
  # Compile CoffeeScript...
  guard 'coffeescript', coffeescript_options do
    coffeescript_options[:patterns].each { |pattern| watch(pattern) }
  end
  # ... and uglify JavaScript
  guard 'uglify',
    input: 'src/foundation-player.js',
    output: 'src/foundation-player.min.js'

end
