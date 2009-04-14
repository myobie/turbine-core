class Audio < PostType
  fields :audio_url, :description, :embed
  required :audio_url
  primary :description
  
  def self.detect?(text)
    has_required? text
  end
end