class Audio < PostType
  fields :audio_url, :description, :embed
  required :audio_url
  primary :description
  
  html do
    haml %Q{
      - unless blank_attr?(:embed)
        .embed= get_attr(:embed)

      %p.url
        %a{:href=>get_attr(:audio_url)}= get_attr(:audio_url)

      ~ get_attr(:description)
    }.indents(true)
  end
  
  def self.detect?(text)
    has_required? text
  end
end