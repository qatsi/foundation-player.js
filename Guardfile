coffeescript_options_src = {
  input: '.',
  output: '.',
  patterns: [%r{^(.*/.+\.(?:coffee|coffee\.md|litcoffee))$}]
}

group :all_the_stuff, halt_on_fail: true do
  # Compile CoffeeScript files
  guard 'coffeescript', coffeescript_options_src do
    coffeescript_options_src[:patterns].each { |pattern| watch(pattern) }
  end

  # Uglify main JavaScript file
  guard 'uglify',
        input: 'src/foundation-player.js',
        output: 'src/foundation-player.min.js'

  # Compile HAML
  guard :haml, notifications: true do
    watch(/^.+(\.haml)$/)
  end

  # Compile SCSS
  guard :compass, project_path: '.', compile_on_start: true do
    watch(/.*\.scss$/)
  end

  # Update browser
  guard 'livereload' do
    watch(%r{^spec/javascripts/.*/(.*)\.js})
    watch(%r{^spec/javascripts/(.*)\.js})
    watch(%r{^src/(.*)\.js})
    watch(%r{^src/(.*)\.css})
    watch(/^index\.html/)
  end
end
