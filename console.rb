# pp Rails.methods.sort
autoloader = Rails.autoloaders.main
classes = []
autoloader.on_load { |_path, value, _aPath| classes << value }
autoloader.eager_load
pp classes[3].instance_methods
# pp Box.instance_methods
