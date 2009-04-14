class Video < PostType
  fields :video_url, :description, :embed, :url
  required :video_url
  primary :description
  
  special :url do |link_content|
    'http://' + link_content.gsub(/^http:\/\//, '')
  end
  
  def self.detect?(text)
    has_required? text
  end
end