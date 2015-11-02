# Compile CoffeeScript and uglify JavaScript
coffeescript_options = {
  input: 'src',
  output: 'src',
  patterns: [%r{^src/(.+\.(?:coffee|coffee\.md|litcoffee))$}]
}

guard 'coffeescript', coffeescript_options do
  coffeescript_options[:patterns].each { |pattern| watch(pattern) }
end

# Compile HAML
guard :haml, notifications: true do
  watch(/^.+(\.haml)$/)
end

# Compass
guard :compass, project_path: '.', compile_on_start: true do
  watch(%r{.*\.scss$})
end
