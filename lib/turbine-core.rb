require 'rubygems'
require 'extlib'

include FileUtils

%w( ext importers/hash_importer importers/json_importer importers/string_importer post_type types/article types/audio types/chat types/link types/photo types/quote types/review types/video ).each do |file|
  require "#{File.dirname(__FILE__)}/turbine-core/#{file}.rb"
end