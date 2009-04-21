class Article < PostType
  fields :title, :body, :category
  required :body
  primary :body
  heading :title
  
  html do
    haml %Q{
      - unless blank_attr?(:title)
        %h2= get_attr(:title)

      - unless blank_attr?(:category)
        %p.category
          Category:
          = get_attr(:category)

      ~ get_attr(:body)
    }.indents(true)
  end
  
  def self.detect?(text)
    true # it can always be an article, so make this last in the preferred order
  end
end