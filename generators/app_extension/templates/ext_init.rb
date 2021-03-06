# load Dispatcher if not present yet
unless defined?(ActionController) and defined?(ActionController::Dispatcher)
  require 'action_controller/dispatcher'
end

require File.join(File.dirname(__FILE__), '<%= file_name %>_routing_extension')
require File.join(File.dirname(__FILE__), '<%= file_name %>_dependencies')

# Routing Extension
ActionController::Routing::RouteSet.send :include, <%= class_name %>RoutingExtension

# Load paths go after rails app's own lib/, before previously loaded plugins
ali = $LOAD_PATH.index(File.join(RAILS_ROOT, 'lib')) || 0
paths = [
  File.expand_path(File.join(File.dirname(__FILE__), '..', 'app', 'controllers')),
  File.expand_path(File.join(File.dirname(__FILE__), '..', 'app', 'helpers')),
  File.expand_path(File.join(File.dirname(__FILE__), '..', 'app', 'models')),
  File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
]
paths.each do |p|
  $LOAD_PATH.insert(ali + 1, p)
  Dependencies.load_paths << p
end

# Views will also look here in the plugin.
# We use prepend_* to put this directory as a high priority, ahead of any previously loaded plugins.
# That way if you are following another plugin, but providing specific overrides they can take effect.
# If you want these to be lower priority, use append_ instead of prepend_.
#
# Google "Evil Twin Plugin" on errtheblog for more info.
ActionController::Base.prepend_view_path File.join(File.dirname(__FILE__), '..', 'app', 'views')

# copy in assets
if File.directory?(File.join(File.dirname(__FILE__), '..', 'public'))
  require 'fileutils'
  ['javascripts', 'stylesheets', 'images'].each do |type|
    p_path = File.join(File.dirname(__FILE__), '..', 'public', type)
    next if Dir[File.join(p_path, '*')].empty?
    r_path = File.join(RAILS_ROOT, 'public', type, '<%= file_name %>')
    FileUtils.mkdir_p(r_path) unless File.directory?(r_path)
    Dir["#{p_path}/*"].each do |asset|
      # only copy in files that aren't there yet
      unless File.exist?(File.join(r_path, File.basename(asset)))
        FileUtils.cp_r(asset, r_path)
      end
    end
  end
end
