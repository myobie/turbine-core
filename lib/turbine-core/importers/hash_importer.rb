class HashImporter
  
  attr_accessor :result, :type
  
  def initialize(type)
    @type = type
    @result = {}
  end
  
  def import(hash)
    @result = hash
  end
  
end