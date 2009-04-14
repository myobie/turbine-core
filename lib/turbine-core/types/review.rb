class Review < PostType
  fields :rating, :item, :description, :url
  required :rating, :item
  primary :description
  heading :item
  
  special :rating do |rating_content|
    rating_content.to_f
  end
  
  special :url do |link_content|
    'http://' + link_content.gsub(/^http:\/\//, '')
  end
  
  def self.detect?(text)
    has_required? text
  end
end