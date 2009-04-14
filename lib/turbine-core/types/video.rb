class Video < PostType
  fields :video_url, :description, :embed
  required :video_url
  primary :description
  
  def self.detect?(text)
    has_required? text
  end
end