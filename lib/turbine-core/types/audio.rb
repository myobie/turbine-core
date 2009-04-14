class Audio < PostType
  fields :audio_url, :description, :embed, :url
  required :audio_url
  primary :description
  heading :title
  
  special :url do |link_content|
    'http://' + link_content.gsub(/^http:\/\//, '')
  end
  
  def self.detect?(text)
    has_required? text
  end
end