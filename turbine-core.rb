require 'rubygems'
require 'extlib'

include FileUtils

Dir["lib/**/*.rb"].each do |file_path|
  require file_path
end