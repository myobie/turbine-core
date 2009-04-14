require 'json'

class Json < String; end # just so that we know which importer to run

class JsonImporter
  
  attr_accessor :result, :type
  
  def initialize(type)
    @type = type
    @result = {}
  end
  
  def import(json_text)
    @result = JSON.parse(json_text)
  end
  
end