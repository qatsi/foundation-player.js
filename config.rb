# Require any additional compass plugins here.
add_import_path  File.join(
  $LOAD_PATH.select{ |v| v =~ /foundation-rails/ }.first,
  '..', 'vendor', 'assets', 'stylesheets')

# Set this to the root of your project when deployed:
http_path = '/'
css_dir = 'src'
sass_dir = 'src'
images_dir = 'src/images'
javascripts_dir = 'src'

# One of: :nested, :expanded, :compact, or :compressed
output_style = :nested
# line_comments = false
