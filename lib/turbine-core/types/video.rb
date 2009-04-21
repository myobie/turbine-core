class Video < PostType
  fields :video_url, :description, :embed
  required :video_url
  primary :description
  
  html do
    haml %Q{
      - unless blank_attr?(:embed)
        .embed= get_attr(:embed)

      %p.url
        %a{:href=>get_attr(:video_url)}= get_attr(:video_url)

      ~ get_attr(:description)
    }.indents(true)
  end
  
  def self.detect?(text)
    has_required? text
  end
end