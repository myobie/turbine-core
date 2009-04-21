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
  
  html do
    haml %Q{
      %h2
        - if get_attr?(:url)
          %a{:href=>get_attr(:url)}= get_attr(:item)
        - else
          = get_attr(:item)

      %p
        Rating:
        = get_attr(:rating)

      ~ get_attr(:description)
    }.indents(true)
  end
  
  def self.detect?(text)
    has_required? text
  end
end